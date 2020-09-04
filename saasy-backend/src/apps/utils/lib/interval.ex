defmodule Util.Interval do
  @moduledoc """
  Timer to schedule jobs in small intervals.

  You can also use :timer.apply_interval(microsecs, Module, :func, [args])

  What this gives is the ability to adjust the interval through the state
  argument, as well as a supervisor (TBD)

  Note: this is still a WIP, and is not currently used (or should not be)

  Problems:
    * the current call of a method should
  """
  use GenServer

  # state = %{ets: table_name}) do
  def start_link(state) do
    # :ets.new(table_name, [:set, :protected, :named_table, read_concurrency: true])
    GenServer.start_link(__MODULE__, state)
  end

  # I know we shouldn't use error handling for flow control, but this was
  # a quick way to identify if the table is there or not -BJG
  #### not worth it as we always start with a fresh ETS table...
  # def create_ets_table(table_name) do
  #   :ets.lookup(table_name, :state)
  # rescue
  #   ArgumentError ->
  #     :ets.new(table_name, [:set, :protected, :named_table, read_concurrency: true])
  # end

  def init(state = %{module: module}) do
    state = apply(module, :init, [state])

    # if :ets is defined, create a table to retain state in for others to read
    # case state do
    #   %{ets: table_name} ->
    #     :ets.new(table_name, [:set, :protected, :named_table, read_concurrency: true])
    # end

    # initialize
    queue_interval(0)
    {:ok, state}
  end

  # the function call pattern match is to verify it's in the state, but we
  # ignore it and instead pull it from the resulting output, unless we fail
  # where we instead use the prior interval
  def handle_info(:interval, %{interval: _interval} = state) do
    state = %{interval: interval} = run_interval(state)

    # case state do
    #   %{ets: table_name} ->
    #     IO.puts("Inserting into ETS table")
    #     :ets.insert(table_name, {:state, state})
    # end

    queue_interval(interval)
    {:noreply, state}
  end

  defp run_interval(state = %{module: module}),
    do: apply(module, :interval, [state])

  defp queue_interval(interval) do
    Process.send_after(self(), :interval, interval)
  end
end
