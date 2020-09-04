defmodule Plug.QuietLogger do
  @moduledoc """
  Supresses logging for configured requests. By default, `/health-check`.
  Kubernetes frequently calls this for checking the health of an application.
  We don't want to flood the logs with this "noise".

  NOTE: This comes from https://github.com/Driftrock/quiet_logger/blob/master/lib/plug/quiet_logger.ex

  However, since it is so simple, it was just brought in.
  """
  @behaviour Plug

  def init(opts) do
    path = Keyword.get(opts, :path, "/health-check")
    log = Keyword.get(opts, :log, :info)

    %{log: log, path: path}
  end

  def call(%{request_path: path} = conn, %{log: log, path: paths}) when is_list(paths) do
    if path in paths, do: conn, else: Plug.Logger.call(conn, log)
  end

  def call(%{request_path: path} = conn, %{log: :info, path: path}), do: conn

  def call(conn, %{log: log}) do
    Plug.Logger.call(conn, log)
  end
end
