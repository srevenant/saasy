defmodule Mix.Tasks.Authkey do
  use Mix.Task
  # alias Utils.Types
  use Core.ContextClient

  @shortdoc "generate an Authorization header key for dev testing"

  def start_friends() do
    {:ok, _} = Application.ensure_all_started(:core)
    {:ok, _} = Application.ensure_all_started(:timex)
    {:ok, _} = Application.ensure_all_started(:faker)
    Utils.Mix.ensure_started(Core.Repo, [])
  end

  def syntax(error) do
    start_friends()

    IO.puts("""
    Syntax: mix authkey {user-id}

    {user-id}    (str) uuid for the user to be authenticated

    Run mix core.tenant list-users for a list of users
    """)

    if error do
      IO.puts("\n>> #{error}")
    end
  end

  def get_secret(type, secret) when is_nil(secret) do
    AuthX.Settings.current_jwt_secret(type)
  end

  def get_secret(_type, secret) when is_binary(secret) do
    Base.decode64!(secret)
  end

  def run([user_id]) do
    AuthX.Settings.start()
    {:ok, _} = Application.ensure_all_started(:core)
    {:ok, _} = Application.ensure_all_started(:timex)
    Utils.Mix.ensure_started(Core.Repo, [])

    {:ok, user} = Users.one([id: user_id], [:tenant])

    ### TODO: have it lookup existing validation tokens, rather than making new
    {:ok, _, _, factor} = AuthX.Token.Requests.validation_token(user, %{"t" => "refresh"}, :user)

    # enrich the factor data
    factor = %Factor{factor | user: user}

    result = AuthX.Token.Requests.access_token(factor)

    case result do
      {:error, reason} ->
        syntax(reason)

      nil ->
        syntax("Missing configuration as array: jwt_shared_secrets?")

      token ->
        IO.puts("Your token (usable for 1 day)\n\nbearer #{token}\n")
    end
  end

  def run(args), do: syntax("Invalid Arguments: #{Enum.join(args, " ")}")
end
