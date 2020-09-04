defmodule WebSvc.TestSupportAuth do
  import Core.Test.Factory
  use Core.ContextClient
  alias Plug.Conn

  def auth_header(%Core.Model.Factor{} = factor) do
    {:ok, factor} = Factors.preload(factor, [:user])
    {:ok, user} = Users.preload(factor.user, [:tenant])

    "Bearer " <>
      AuthX.Token.Requests.create(
        sub: "cas1:" <> factor.id,
        exp: 10,
        tenant_code: user.tenant.code,
        type: :acc
      ).token
  end

  def auth_header(%Core.Model.User{} = user) do
    # {:ok, user} = Users.preload(user, :factors)
    %Factor{} = valtok = Enum.find(user.factors, fn f -> f.type == :valtok end)

    "Bearer " <>
      AuthX.Token.Requests.create(
        sub: "cas1:" <> valtok.id,
        exp: 10,
        tenant_code: user.tenant.code,
        type: :acc
      )
  end

  def auth_header(sub, exp, tenant_code, type) when is_binary(tenant_code) do
    "Bearer " <>
      AuthX.Token.Requests.create(sub: sub, exp: exp, tenant_code: tenant_code, type: type).token
  end

  def headers_for_factor(conn, %Core.Model.Factor{} = factor) do
    {:ok, factor} = Factors.preload(factor, :user)

    conn
    |> Conn.put_req_header("authorization", auth_header(factor))
    |> Conn.assign(:user, factor.user)
  end

  def headers_for_user(conn, %Core.Model.User{} = user) do
    conn
    |> Conn.put_req_header("host", user.tenant.domain)
    |> Conn.put_req_header("authorization", auth_header(user))
    |> Conn.assign(:user, user)
  end

  def headers_for_graphql(conn, %Core.Model.User{} = user) do
    conn
    |> headers_for_user(user)
    |> Conn.put_req_header("content-type", "application/graphql")
    |> Conn.put_req_header("x-api-version", "1")
  end

  #
  # def headers_for_api(conn, %Core.Model.User{} = user) do
  #   conn
  #   |> headers_for_user(user)
  #   |> Conn.put_req_header("content-type", "application/json")
  # end
  #
  # def headers_for_api(conn, %Core.Model.Factor{} = factor) do
  #   conn
  #   |> headers_for_factor(factor)
  #   |> Conn.put_req_header("content-type", "application/json")
  # end
  #
  # def headers_for_api(conn, sub, exp, tenant_code, type) when is_binary(tenant_code) do
  #   conn
  #   |> Conn.put_req_header("authorization", auth_header(sub, exp, tenant_code, type))
  #   |> Conn.put_req_header("content-type", "application/json")
  # end

  def setup_tenant() do
    test_host = Utils.RandChars12.random()

    {:ok, %Core.Model.Tenant{} = tenant} = Core.Model.Tenants.create_tenant(test_host)

    {tenant, test_host}
  end

  def test_tenant_user() do
    {tenant, test_host} = setup_tenant()

    user = insert(:user, tenant_id: tenant.id, tenant: tenant)

    insert(:factor, user: user, type: :password)
    insert(:factor, user: user, type: :valtok)

    user = Factors.preloaded_with(user, [:password, :valtok])

    {:ok, %{user: user, host: test_host}}
  end

  def setup_graphql(%{conn: conn} = args) do
    {:ok, %{user: user}} = test_tenant_user()

    {:ok,
     args
     |> Map.put(:conn, headers_for_graphql(conn, user))
     |> Map.put(:user, user)}
  end
end
