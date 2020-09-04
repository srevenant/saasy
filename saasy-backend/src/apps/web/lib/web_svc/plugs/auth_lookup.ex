defmodule WebSvc.AuthLookup do
  @moduledoc """
  comes after Auth Lookup User, if no user, you are redirected to auth page
  """
  @behaviour Plug
  use Core.ContextClient
  import Users, only: [check_user_status: 1]
  import Plug.Conn
  alias Web.Auth
  alias AuthX.Token

  def init(opts), do: opts

  # CORE PROBLEM: GraphQL doesn't want sessions. But sessions are good.
  def call(conn, _args) do
    # pull session info (host->tenant, session data)
    with conn <- fetch_session(conn),
         {:ok, tenant} <- AuthX.get_tenant(conn) do
      # track the tenant on the connection struct
      conn = assign(conn, :tenant, tenant)

      # if a new connection and no session ID, create one
      conn =
        case get_session(conn, :id) do
          nil ->
            put_session(conn, :id, Ecto.UUID.generate())

          _ ->
            conn
        end

      # clean authdomain so we don't leak info -- TODO: consider two types of
      # auth domain (during auth, and after auth) (BJG)
      auth = %AuthDomain{tenant: tenant}

      case conn
           |> get_req_header("authorization")
           |> proc_auth_header(auth) do
        {:ok, %AuthDomain{status: :authed} = auth} ->
          Auth.session_user(conn, %AuthDomain{auth | tenant: tenant})

        {:missing, %AuthDomain{}} ->
          # no Bearer token, but session has a user_id -- only allow if user is an identity user
          case get_session(conn, :user_id) do
            nil ->
              Auth.session_user(conn, tenant)

            user_id ->
              case Users.one(id: user_id) do
                # only accept identity users this way
                {:ok, %User{type: :identity} = user} ->
                  Auth.session_user(conn, %AuthDomain{
                    status: :identified,
                    user: user,
                    tenant: tenant
                  })

                _other ->
                  Auth.session_user(conn, tenant)
              end
          end

        {_, %AuthDomain{}} ->
          Auth.session_user(conn, tenant)
      end
    else
      {:error, msg} ->
        Logger.error(msg)
        Auth.did_signout(conn)
    end
  end

  ##############################################################################

  # if authorization header is missing
  def proc_auth_header([], %AuthDomain{} = auth),
    do: {:missing, %AuthDomain{auth | log: "Missing authorization header"}}

  def proc_auth_header([header], %AuthDomain{} = auth) do
    with ["", token] <- Regex.split(~r/Bearer:? /i, header, parts: 2) do
      # look into DRYing this out (refresh uses similar code)
      case Token.validate_by_type(:acc, token) do
        {:error, reason} ->
          {:error, %AuthDomain{auth | log: reason}}

        {:ok, result} ->
          auth = %AuthDomain{auth | status: :authed, token: %{ref: token, claims: result}}

          # this checks the validation token embedded within the refresh token
          case Token.check(auth) |> check_user_status do
            {:ok, %AuthDomain{} = auth} ->
              {:ok, auth}

            {:error, %AuthDomain{} = auth} ->
              # we passed signature, but the claims weren't right
              {:error, %AuthDomain{auth | status: :unknown}}
          end
      end
    else
      _ -> {:missing, %AuthDomain{auth | log: "Missing valid authorization header"}}
    end
  end
end
