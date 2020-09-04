defmodule WebSvc.PageControllerTest do
  use WebSvc.ConnCase

  setup _ do
    {_tenant, test_host} = WebSvc.TestSupportAuth.setup_tenant()

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("host", test_host)

    %{conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "<!-- aWNlbnRyaXMK"
  end
end
