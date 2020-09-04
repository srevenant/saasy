defmodule Web.Auth do
  @moduledoc """
  Functions to assist w/auth cycle (such as in view rendering)

  session_user/3 manages most of the session setting/clearing.  However,
  we track both a session id separate from the user id.  This is so we can
  uniquely identify a session even if we don't know who the user is (yet).

  To support this, session id is set by the plugin if it doesn't exist,
  and it is only cleared on signout (did_signout/1).

  Because session_user is called on each connection, even the ones where
  we don't have a user signin, if session_user cleared the session id
  when there was no user, we'd gain no value in having a separate session id.
  """

  require Logger
  import Plug.Conn
  alias Core.Model.{User, Users, AuthDomain, Tenant}

  # convenience wrapper that extracts user/tenant
  def did_signin(
        conn,
        %AuthDomain{status: :authed, user: %User{} = user, tenant: %Tenant{} = tenant} = auth
      )
      when not is_nil(user) and not is_nil(tenant) do
    session_user(conn, auth)
  end

  def did_signin(_conn, _auth) do
    IO.puts("Unexpected auth error: Parameters for Web.Auth.did_signin are not correct")
    :error
  end
  # 
  # # see moduledoc info
  # defp signout_identified_user(%{assigns: %{user: %User{type: :identity, id: id}}}, conn) do
  #   with {:ok, user = %User{type: :identity}} <- Users.one(id: id) do
  #     Users.update(user, %{type: :identity_signedout})
  #   end
  #
  #   conn
  # end

  defp signout_identified_user(conn), do: conn

  def did_signout(conn) do
    conn
    |> signout_identified_user
    |> delete_session(:id)
    |> session_user
  end

  # see moduledoc info
  # zero out the session info (which may endup persisting across browsers)
  def session_user(conn) do
    levelset_session(conn, nil, nil, nil, %AuthDomain{})
  end

  def session_user(conn, %Tenant{} = tenant) do
    levelset_session(conn, nil, nil, tenant, %AuthDomain{tenant: tenant})
  end

  def session_user(
        conn,
        %AuthDomain{
          user: %User{} = user,
          tenant: %Tenant{} = tenant
        } = auth
      ) do
    Users.user_seen(user)
    levelset_session(conn, user, user.id, tenant, auth)
  end

  defp levelset_session(conn, user, user_id, tenant, auth) do
    conn
    |> put_session(:user_id, user_id)
    |> assign(:tenant, tenant)
    |> assign(:auth, auth)
    |> assign(:user, user)
    |> Absinthe.Plug.put_options(context: %{user: user, tenant: tenant, auth: auth})
  end
end
