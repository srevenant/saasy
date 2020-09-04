defmodule AuthX do
  @moduledoc """
  Documentation for AuthX.
  """

  require Logger
  require Regex
  alias Plug.Conn
  alias Core.Model.{UserCode, UserCodes}
  use Core.ContextClient

  def log(msg, labels \\ []) when is_binary(msg) do
    Logger.info(msg, labels)
  end

  def conn_abort_redirect(conn, reason, redirect) do
    conn
    |> Conn.put_resp_header("location", AuthX.Settings.getcfg(:base_path) <> redirect)
    |> conn_abort(reason)
  end

  # log errors with details, but return a simple 'unauthorized' for user visibility
  def user_error(reason, labels \\ [])
  def user_error(reason, _) when reason == "unauthorized", do: reason

  def user_error(reason, labels) do
    Logger.error(reason, labels)
    "unauthorized"
  end

  # this reason is for the user
  def conn_abort(conn, user_reason) when is_binary(user_reason) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(403, "{\"error\": \"#{user_reason}\"}")
    |> Conn.halt()
  end

  def load_tenant(conn) do
    case get_tenant(conn) do
      {:ok, %Tenant{} = tenant} ->
        # conn = Conn.assign(conn, :tenant, tenant)
        Logger.metadata(tid: tenant.code)
        {:ok, %AuthDomain{tenant: tenant}}

      {:error, reason} ->
        # conn = Conn.assign(conn, :tenant, "unknown")
        Logger.metadata(tid: "unknown")
        {:error, %AuthDomain{log: reason || "Unknown"}}
    end
  end

  def get_tenant(%Plug.Conn{} = conn) do
    case Conn.get_req_header(conn, "host") do
      [host] -> Tenants.host_to_tenant(host)
      # {inspect(hdr)}"}
      _hdr -> {:error, "Cannot identify target host"}
    end
  end

  #
  # def get_tenant(%Plug.Conn{} = conn) do
  #   case Conn.get_req_header(conn, "host") do
  #     [host] -> Tenants.host_to_tenant(host)
  #     _ -> {:error, "Cannot identify target host"}
  #   end
  # end

  def get_tenant(domain) when is_binary(domain), do: Tenants.host_to_tenant(domain)

  @spec create_apikey(User.t(), Map.t()) :: {:ok, Factor.t()} | {:error, any}
  def create_apikey(%User{} = user, details \\ %{})
      when is_map(details) do
    secret = Utils.RandChars48.random()

    Factors.create(%{
      name: "apikey",
      type: :apikey,
      user_id: user.id,
      value: secret,
      details: details,
      expires_at: Utils.Time.epoch_time(:second) + 365 * 86400
    })
  end

  ##############################################################################
  @expire_minutes 60
  def send_reset_code(%UserEmail{user: %User{} = user} = email) do
    UserCodes.clear_all_codes(user.id, :password_reset)

    case UserCodes.generate_code(user.id, :password_reset, @expire_minutes) do
      {:ok, code} ->
        Users.send_password_reset(user, email, code)
        :ok

      error ->
        IO.inspect(error, label: "Cannot generate UserCode?")
        :error
    end
  end

  def change_password(eaddr, current, new) when is_binary(eaddr) do
    case UserEmails.one([address: eaddr], [:user]) do
      {:ok, email} ->
        change_password(email.user, current, new)

      _error ->
        :error
    end
  end

  def change_password(%User{} = user, current, new) do
    # try password first
    case AuthX.Signin.Local.check_password(user, current) do
      true ->
        :ok

      _ ->
        # try a reset user code
        case UserCodes.one(user_id: user.id, code: current) do
          {:ok, %UserCode{} = code} ->
            UserCodes.delete(code)
            :ok

          _error ->
            Logger.warn("password change failure: current password or code mis-match",
              user_id: user.id
            )

            :error
        end
    end
    # the output of above is either :ok or :error
    |> case do
      :error ->
        :error

      :ok ->
        case Factors.set_password(user, new) do
          {:ok, %Factor{}} ->
            Users.send_password_changed(user)
            :ok

          {:error, _} ->
            :error
        end
    end
  end
end
