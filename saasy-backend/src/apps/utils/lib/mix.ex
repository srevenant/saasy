defmodule Utils.Mix do
  # from Ecto.Mix 2.x, deprecated in 3.x
  def ensure_started(repo, opts) do
    {:ok, started} = Application.ensure_all_started(:ecto)

    # If we starting Ecto just now, assume
    # logger has not been properly booted yet.
    if :ecto in started && Process.whereis(Logger) do
      backends = Application.get_env(:logger, :backends, [])

      try do
        Logger.App.stop()
        Application.put_env(:logger, :backends, [:console])
        :ok = Logger.App.start()
      after
        Application.put_env(:logger, :backends, backends)
      end
    end

    {:ok, apps} = repo.__adapter__.ensure_all_started(repo, :temporary)

    pool_size = Keyword.get(opts, :pool_size, 1)

    case repo.start_link(pool_size: pool_size) do
      {:ok, pid} ->
        {:ok, pid, apps}

      {:error, {:already_started, _pid}} ->
        {:ok, nil, apps}

      {:error, error} ->
        Mix.raise("Could not start repo #{inspect(repo)}, error: #{inspect(error)}")
    end
  end
end
