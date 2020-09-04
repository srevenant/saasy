defmodule WebSvc.PageController do
  use WebSvc, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  @doc """
  dummy endpoint to deal with OPTIONS preflight CORS requests
  """
  def options(conn, _params) do
    conn
  end
end
