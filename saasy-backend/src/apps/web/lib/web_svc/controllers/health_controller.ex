defmodule WebSvc.HealthController do
  use WebSvc, :controller
  alias Core.HealthStatus

  def status(conn, params) do
    case HealthStatus.status(params) do
      :ok -> send_resp(conn, :no_content, "")
      {:ok, data} -> json(conn, data)
      :bad -> send_resp(conn, :service_unavailable, "")
      {:bad, _data} -> send_resp(conn, :service_unavailable, "")
    end
  end
end
