defmodule Web.AuthHelpers do
  @moduledoc """
  Functions to assist w/auth cycle (such as in view rendering)
  """
  require Logger

  @doc """
  Is the current user allowed to do a thing (grant), where thing
  is an action mapped via user->roleMap->Role->[Actions], loaded
  into user.authz as atoms.
  """
  # note: authz is loaded by the user plugin, so don't bother checking if it exists -BJG
  @spec authorized(conn :: %Plug.Conn{}, grant :: atom()) :: boolean()
  # no grant
  def authorized(conn, []), do: authorized(conn)

  # grant must exist in user.authz
  def authorized(%Plug.Conn{assigns: %{user: %Core.Model.User{} = user}}, grant) do
    grant in user.authz
  end

  # grant as list (only first elem)
  def authorized(conn, [grant]), do: authorized(conn, grant)

  # no user, then the grant isn't authorized
  def authorized(_conn, _grant), do: false

  # or, if no grant is needed, it's true if the user is signed in
  @spec authorized(conn :: %Plug.Conn{}) :: boolean()
  def authorized(%Plug.Conn{assigns: %{user: %Core.Model.User{}}}), do: true
  def authorized(_), do: false
end
