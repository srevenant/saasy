defmodule WebSvc.AuthXController do
  @moduledoc """
  AuthX Controller

  Start with signon, then refresh.  See complete docs in google doc.
  """
  use WebSvc, :controller
  require Logger
  alias Core.Model.{AuthDomain, User, Users, Tenant}

  ##############################################################################
  @doc """
  multi tenant user signup
  """

  # this is to more easily read through the calls internally.  For now,
  # just check for what is uniform across all calls, so we don't have to
  # repeat it later
  def signon(
        conn = %Plug.Conn{assigns: %{tenant: %Tenant{} = tenant}},
        params
      )
      when not is_nil(tenant) and is_map(params) do
    in_signon(conn, tenant, params)
  end

  def signon(conn, params) do
    IO.inspect({conn.assigns, params}, label: "bad signon data")
    conn
  end

  #### GOOGLE - returning user
  defp in_signon(conn, tenant, params = %{"type" => "google"})
       when not is_nil(tenant) do
    AuthX.Signin.Google.create(tenant, params)
    |> after_signon(conn)
  end

  #### LOCAL - returning user
  defp in_signon(conn, tenant, params = %{"signup" => false}) do
    AuthX.Signin.Local.check(tenant, params)
    |> after_signon(conn)
  end

  #### LOCAL - new user
  defp in_signon(conn, tenant, params = %{"signup" => true}) do
    AuthX.Signin.Local.create(tenant, params)
    |> after_signon(conn)
  end

  #### ERROR
  defp in_signon(conn = %Plug.Conn{}, _tenant, params) do
    Logger.info("Failed to match a condition with these payload keys.  Is the tenant configured?",
      keys: Map.keys(params)
    )

    send_failure(
      conn,
      "Input parameters don't match any condition we can use!",
      "Unable to Sign in"
    )
  end

  ##############################################################################
  # after_signon is a pipeline grouping of other post-signin methods,
  # so the various signin function above don't have to have extra imperative
  # logic for their contexts.  Although each function is called below, the function
  # should only enrich or after_signon if it's context matches
  defp after_signon({:ok, %AuthDomain{} = auth}, conn) do
    {:ok, auth, conn}
    |> create_validation_factor
    |> set_user_auth_type
    |> update_conn
  end

  defp after_signon({:error, %AuthDomain{error: error, log: failure}}, conn),
    do: send_failure(conn, failure, error)

  ##############################################################################
  defp set_user_auth_type({:ok, %AuthDomain{user: %User{type: :identity} = user} = auth, conn}) do
    {:ok, user} = Users.update(user, %{type: :authed})
    {:ok, %AuthDomain{auth | user: user}, conn}
  end

  defp set_user_auth_type({:ok, %AuthDomain{user: %User{type: :authed}}, _} = pass),
    do: pass

  defp set_user_auth_type({:ok, %AuthDomain{user: %User{type: :unknown}}, _}) do
    {:error, "unexpectedly received user with type: unknown"}
  end

  defp set_user_auth_type({:error, _} = pass),
    do: pass

  ##############################################################################
  @doc """
  Validate the refresh token sent by the client and returns an access token
  """
  def refresh(conn = %Plug.Conn{assigns: %{tenant: tenant}}, params) do
    case AuthX.Refresh.assure(%AuthDomain{tenant: tenant}, params) do
      # both reference token and validation token are acceptable
      {:ok, %AuthDomain{status: :authed}, %AuthDomain{status: :authed, factor: factor}} ->
        token = AuthX.Token.Requests.access_token(factor)
        Logger.info("Valid Access Token")

        conn
        |> json(%{access_token: token})

      {:error, %AuthDomain{} = auth} ->
        conn |> send_failure(auth)
    end
  end

  ##############################################################################
  defp create_validation_factor({:ok, %AuthDomain{user: %User{}} = auth, conn}) do
    with {:ok, token, secret, _factor} <-
           AuthX.Token.Requests.validation_token(
             auth.user,
             %{"t" => "refresh"},
             :user
           ) do
      {:ok,
       %AuthDomain{
         auth
         | token: %{
             sub: "cas2:" <> token,
             aud: "caa1:ref:#{auth.tenant.code}",
             sec: secret,
             next: "/auth/v1/api/refresh"
           }
       }, conn}
    else
      err ->
        {:error, %AuthDomain{auth | log: "Unable to create validaton token #{inspect(err)}"},
         conn}
    end
  end

  defp create_validation_factor({:error, %AuthDomain{}, _conn} = pass), do: pass

  ##############################################################################
  defp update_conn({:ok, %AuthDomain{status: :authed} = auth, conn}) do
    case Web.Auth.did_signin(conn, auth) do
      :error ->
        send_failure(conn, "Unexpected Error", "Sign in failed")

      response ->
        Logger.info("Valid User Sign", uid: auth.user.id)
        json(response, auth.token)
    end
  end

  # should not happen...
  defp update_conn({:ok, %AuthDomain{status: :unknown, log: failure, error: _}, conn}) do
    failure =
      "Unexpected auth failure!" <>
        case is_nil(failure) do
          false -> " - " <> failure
          true -> ""
        end

    send_failure(conn, failure, "Sign in failed")
  end

  defp update_conn({:error, %AuthDomain{log: failure, error: error}, conn}),
    do: send_failure(conn, failure, error)

  ##############################################################################
  def send_failure(conn, %AuthDomain{log: failure, error: error}),
    do: send_failure(conn, failure, error)

  def send_failure(conn, failure, error) do
    if not is_nil(failure) and String.length(failure) > 0 do
      Logger.error(failure)
    end

    error =
      if not is_nil(error) and String.length(error) > 0 do
        error
      else
        "Sign in Failed"
      end

    conn
    |> json(%{signin: false, reason: error})
  end

  @doc """
  dummy endpoint to deal with OPTIONS preflight CORS requests
  """
  def options(conn, _params) do
    conn
  end

  @doc """
  """
  def signout(conn, _params) do
    Web.Auth.did_signout(conn)
    |> send_resp(:no_content, "")
  end

  ##############################################################################
  defp identify_limit(conn, reason, remote_ip, {code, msg} \\ {429, "too many requests"}) do
    Logger.warn("rate limit", endpoint: "authx/identify", remote_ip: remote_ip, reason: reason)
    conn |> send_resp(code, msg)
  end

  defp identify_email(conn, tenant, eaddr, remote_ip) do
    case AuthX.Identify.identify(tenant, %{email: eaddr}) do
      {:ok, auth} ->
        conn
        |> put_session(:user_id, auth.user.id)
        |> send_resp(:no_content, "")

      {:error, %AuthDomain{error: errmsg}} ->
        identify_limit(conn, errmsg, remote_ip, {406, errmsg})

      {:exists, _} ->
        identify_limit(conn, "email address already exists", remote_ip)
    end
  end

  def identify(conn = %Plug.Conn{assigns: %{tenant: %Tenant{} = tenant}}, %{"email" => eaddr}) do
    case conn |> get_req_header("x-forwarded-for") do
      [remote_ip] ->
        case Hammer.check_rate("identify:#{remote_ip}", 60_000, 1) do
          {:allow, _count} ->
            identify_email(conn, tenant, eaddr, remote_ip)

          # case AuthX.Identify.identify(tenant, %{email: eaddr}) do
          #   {:ok, auth} ->
          #     conn
          #     |> put_session(:user_id, auth.user.id)
          #     |> send_resp(:no_content, "")
          #
          #   other ->
          #     identify_limit(conn, "email already exists", remote_ip)
          # end

          {:deny, _limit} ->
            identify_limit(conn, "too many queries", remote_ip)
        end

      _ ->
        case conn |> get_req_header("origin") do
          # local dev
          ["http://localhost:3000"] ->
            identify_email(conn, tenant, eaddr, nil)

          _ ->
            identify_limit(conn, "missing x-forwarded-for header", nil)
        end
    end
  end
end
