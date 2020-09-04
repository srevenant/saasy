# original content from Protos LLC/Brandon Gillespie, License for use per addendum (exhibit A) to noncompete/nda
defmodule AuthX.Refresh do
  @moduledoc """
  Tooling for the second phase of auth: Refresh

  TODO: Extract from Phoenix/WebSvc better, abstract so conn isn't needed
        This will require a module that is imported into WebSvc -BJG
  """
  require Logger
  alias AuthX.Token
  alias Core.Model.{AuthDomain, Factor}

  ##############################################################################
  # 1. extract the validaton token from the refresh token
  # 2. decode & verify the validation token is ours & good
  # 3. using the sub:uuid from the validation token, verify the signature on the ref token
  # 4. update connection data (or abort)
  # include tenant in %AuthDomain
  def assure(%AuthDomain{} = auth, %{"client_assertion" => token}),
    do: assure(auth, %{"client_assertion_type" => token})

  def assure(%AuthDomain{} = auth, %{"client_assertion_type" => refresh_token}) do
    auth = %AuthDomain{auth | token: %{ref: refresh_token}}

    # do this manually first
    extract_claims(refresh_token)
    |> extract_validation_token(auth)
    |> check_refresh_token
  end

  def assure(_arg, _params) do
    {:error, %AuthDomain{log: "Invalid refresh request"}}
  end

  ################################################################################
  # Break out the claims of a JWT, without any validation
  def extract_claims(token) do
    case String.split(token, ".") |> Enum.at(1) do
      nil ->
        {:error, "Unable to decode outer JWT #{token}"}

      other ->
        case other |> Base.decode64!(padding: false) |> Poison.decode() do
          {:ok, claims} -> {:ok, claims}
          {:error, _msg} -> {:error, "Unable to decode outer JWT #{token}"}
        end
    end
  end

  ##############################################################################
  def extract_validation_token({:ok, %{"sub" => "cas2:" <> validation_token}}, auth) do
    # now check the signature
    case Token.validate_by_type(:val, validation_token) do
      {:error, reason} ->
        {:error, %AuthDomain{auth | log: reason}}

      {:ok, result} ->
        valauth = %AuthDomain{
          auth
          | status: :authed,
            token: %{ref: validation_token, claims: result}
        }

        # this checks the validation token embedded within the refresh token
        case Token.check(valauth) do
          {:ok, %AuthDomain{} = valauth} ->
            {:ok, auth, valauth}

          {:error, %AuthDomain{} = auth} ->
            {:error, auth}
        end
    end
  end

  def extract_validation_token({:error, reason}, auth) when is_binary(reason) do
    {:error, %AuthDomain{auth | log: reason}}
  end

  # turn it into an error if we didn't match above
  def extract_validation_token({:ok, args}, auth),
    do:
      {:error,
       %AuthDomain{auth | log: "Unable to match validation token subject #{inspect(args)}"}}

  ##############################################################################
  def check_refresh_token(
        {:ok, %AuthDomain{token: %{ref: token}} = refauth,
         %AuthDomain{factor: %Factor{value: secret}} = valauth}
      )
      when not is_nil(secret) do
    if Token.verify_jwt!(token, secret) do
      {:ok, %AuthDomain{refauth | status: :authed}, valauth}
    else
      {:error, %AuthDomain{refauth | log: "Unable to verify refresh token signature"}}
    end
  end

  def check_refresh_token(pass = {:error, _reason}), do: pass
end
