defmodule AuthX.TestSupportAuth do
  use Core.ContextClient
  alias AuthX.Token

  def auth_header(%Core.Model.User{} = user) do
    {:ok, _tok, _sec, factor} = AuthX.Token.Requests.validation_token(user, %{}, :user)
    {:ok, user} = Users.preload(user, [:tenant])
    "Bearer " <> Token.Requests.access_token("cas1:#{factor.id}", 10, user.tenant.code).token
  end

  def auth_header(sub, exp, tenant_code, type) when is_binary(tenant_code) do
    "Bearer " <>
      Token.Requests.create(sub: sub, exp: exp, tenant_code: tenant_code, type: type).token
  end
end
