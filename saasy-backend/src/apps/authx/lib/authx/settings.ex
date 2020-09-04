defmodule AuthX.Settings do
  @moduledoc """
  How we are configured globally
  """
  require Logger

  ###########################################################################
  @doc """
  Called by Application.start, to configure the runtime state from other sources
  """
  def decode_secrets(source) do
    key = Utils.Types.to_atom("jwt_#{source}_secrets")

    putcfg(
      Utils.Types.to_atom("#{key}_decoded"),
      Enum.map(getcfg(key), fn x ->
        Base.decode64!(x)
      end)
    )
  end

  def start() do
    decode_secrets(:acc)
    decode_secrets(:val)

    # make a default
    putcfg(:client, %{})

    # putcfg(:scheme, case Core.App.Settings.get("auth_v3", type: :json) do
    #   nil -> AuthX.Signin.Local
    #   meta ->
    #     scheme = "Elixir." <> Map.get(meta, "scheme", "AuthX.Signin.Local")
    #     |> String.to_atom
    #     putcfg(:client, Map.put(meta, "scheme", scheme))
    #     scheme
    # end)

    Logger.info("Configured Authentication", scheme: "#{getcfg(:scheme)}")
  end

  ###########################################################################
  @doc """
  Get the most current secret based on token type(:acc, :val etc..), for jwt hashes
  """
  def current_jwt_secret(token_type) do
    case secret_keys(token_type) do
      [secret | _rest] -> secret
      nil -> raise ArgumentError, "Missing configuration as array: auth:jwt_acc_secrets?"
    end
  end

  ###########################################################################
  def secret_keys(token_type) do
    key =
      case token_type do
        :val ->
          :jwt_val_secrets_decoded

        _ ->
          :jwt_acc_secrets_decoded
      end

    getcfg(key)
  end

  ###########################################################################

  def expire_limit(token_type) do
    exp_config = getcfg(:auth_expire_limits)

    case token_type do
      # TODO handle user types for val token.
      :val ->
        exp_config[token_type][:user]

      _ ->
        exp_config[token_type]
    end
  end

  def getcfg(name), do: Application.get_env(:authx, name)
  def putcfg(name, value), do: Application.put_env(:authx, name, value)
end
