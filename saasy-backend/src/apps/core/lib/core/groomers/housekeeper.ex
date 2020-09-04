defmodule Core.Groomer.Housekeeper do
  @moduledoc """
  Separate process to keep our house clean - an aggregate of lightweight things.

  These should be /very/ lightweight checks.  Anything which takes more than
  a few moments to run should be split into its own genserver.
  """
  require Logger
  use GenServer
  use Core.ContextClient
  alias Core.Model.UserCodes

  defp run_interval(state) do
    Factors.drop_expired()
    UserCodes.clear_expired_codes()
  rescue
    err ->
      Logger.error("Housekeeper had an error #{inspect(err)}")
      state
  end

  ##############################################################################
  # general GenServer things after this

  # standard way for us to request a future interval callback
  defp schedule_next() do
    # 15-mins - maybe make this a config
    Process.send_after(:housekeeper, :interval, 900_000)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: :housekeeper)
  end

  def init(state) do
    schedule_next()
    {:ok, state}
  end

  def handle_info(:interval, state) do
    schedule_next()
    {:noreply, run_interval(state)}
  end

  def handle_call(:get_keys, _from, state = %{keys: keys}) do
    {:reply, keys, state}
  end
end
