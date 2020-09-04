defmodule WebSvc.RedirectController do
  use WebSvc, :controller

  def redirector(conn, _params) do
    redirect(conn, external: Application.get_env(:web, :redirect_target_url))
  end
end
