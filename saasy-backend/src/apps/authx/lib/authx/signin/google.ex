defmodule AuthX.Signin.Google do
  @moduledoc """
  Google login scheme
  """
  require Logger
  use Core.ContextClient
  use AuthX.ContextTypes
  alias Core.Model.{AuthFedId, AuthFedIdEmail, AuthFedIdProvider}
  import AuthX.Signin, only: [find_by_email_and_link: 3]

  ##############################################################################
  # note: this is different from `auth_result` typedef, in it can have any
  # value with :ok, where the second part of auth_result is always an AuthDomain
  @type pipeline_output :: {:ok, any} | {:error, AuthDomain.t()}

  # TODO: leverage profile to populate user data
  @spec create(Tenant.t(), Map.t()) :: auth_result
  def create(
        %Tenant{} = tenant,
        %{
          "data" => %{
            "auth" => %{"idpId" => "google", "id_token" => token},
            "profile" => _profile
          }
        }
      ) do
    # check if already exists, if so link to that
    # otherwise create new profile
    #    path = "https://www.googleapis.com/oauth2/v3/userinfo"
    #    resp = Ueberauth.Strategy.Google.OAuth.get(token, path)
    token
    |> jwt_unverified_decode
    |> google_verify_rs256
    |> link_or_create(tenant)
  end

  def create(_) do
    {:error, %AuthDomain{},
     {"auth signup failed, invalid arguments from client", "Signup Failed"}}
  end

  # TODO: Move this to a separate lib.  Perhaps even clone a lot of google's:
  #   https://github.com/googleapis/google-auth-library-python/blob/master/google/auth/jwt.py

  # decodes the first two segments, but not the last/signature element
  # the Base module is giving errors on it
  @spec jwt_unverified_decode(token :: str) :: pipeline_output
  defp jwt_unverified_decode(token) do
    {:ok,
     {token,
      token
      |> String.split(".")
      |> Enum.slice(0, 2)
      |> Enum.map(fn encoded ->
        encoded
        |> Base.url_decode64!(padding: false)
        |> Poison.decode!()
      end)}}
  rescue
    e in Poison.SyntaxError -> {:error, "Unable to decode jwt: " <> e.message, e}
  end

  @spec google_verify_rs256({:ok, any}) :: pipeline_output
  defp google_verify_rs256({:ok, {token, [header, payload]}})
       when is_map(header) and is_map(payload) do
    # from the unverified decode we pull the google key, and index that against
    # the keys we have from google, to get the pubkey (jwk) that will check the
    # signature of this jwt
    google_keys = AuthX.GoogleKeyManager.get_keys()
    jwk = Map.get(google_keys, header["kid"])
    auth = %AuthDomain{token: token}

    case JOSE.JWT.verify_strict(jwk, ["RS256"], token) do
      {true, %JOSE.JWT{fields: fields}, %JOSE.JWS{} = jws} ->
        {:ok, %{payload: fields, header: Map.from_struct(jws), token: token}}

      {false, %JOSE.JWT{fields: %{"email" => email}}, %JOSE.JWS{}} ->
        {:error, %AuthDomain{auth | log: "Unable to decode google token for #{email}"}}

      {:error, rest} ->
        {:error, %AuthDomain{auth | log: "Unable to decode JWT #{Poison.encode!(rest)}"}}
    end
  end

  @spec google_verify_rs256(pipeline_output) :: auth_result
  defp google_verify_rs256({:error, reason}) when is_binary(reason) do
    {:error, %AuthDomain{log: reason}}
  end

  ##############################################################################
  @spec link_or_create(auth_result, tenant :: Tenant.t()) :: auth_result
  defp link_or_create(
         {:ok,
          %{payload: %{"email_verified" => true, "email" => _email} = payload, header: header}},
         %Tenant{} = tenant
       ) do
    # consider: maybe make this a struct
    # IO.puts(
    #   "Google auth for #{payload["email"]} with claims.jti=#{payload["jti"]} header.kid=#{
    #     header.fields["kid"]
    #   }"
    # )

    fedid = %AuthFedId{
      name: payload["name"],
      handle: UserHandles.gen_good_handle(payload["email"]),
      email: %AuthFedIdEmail{
        address: payload["email"],
        verified: true
      },
      phone: nil,
      settings: %{
        locale: payload["locale"]
      },
      provider: %AuthFedIdProvider{
        type: :google,
        kid: header.fields["kid"],
        jti: payload["jti"],
        iss: payload["iss"],
        iat: payload["iat"],
        exp: payload["exp"],
        azp: payload["azp"],
        aud: payload["aud"],
        token: payload["token"]
      }
    }

    find_by_email_and_link(tenant, fedid, :google)
  end

  # @spec link_or_create(auth_result) :: auth_result
  # defp link_or_create(pass = {:error, %AuthDomain{}}), do: pass
end
