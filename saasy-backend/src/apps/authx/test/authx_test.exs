defmodule WebAuthTest do
  use Core.Case, async: true
  # alias Core.Model.AuthDomain (used in tokens/library test)

  # doctest AuthX.Token.Decode, import: true
  # doctest AuthX.Token.Valid, import: true
  # doctest AuthX.Token.Request, import: true
  # doctest AuthX.Token.Requests, import: true
  # doctest AuthX.Access, import: true
  # doctest AuthX.Refresh, import: true
  doctest AuthX.Signin, import: true
  doctest AuthX.Signin.Local, import: true
  doctest AuthX.Settings, import: true
  doctest AuthX.Token, import: true

  import Core.Test.Factory

  # describe "tokens" do
  #   test "library" do
  #     user = insert(:user)
  #     refresh = AuthX.Token.Requests.refresh_token!(user, %{}, :user, 0)
  #     auth = %AuthDomain{tenant: user.tenant, user: user}
  #
  #     {:ok, %AuthDomain{} = refauth, %AuthDomain{} = valauth} =
  #       AuthX.Refresh.assure(auth, %{"client_assertion" => refresh})
  #
  #     assert refauth.authn == true
  #     assert valauth.authn == true
  #   end
  # end

  describe "apikey" do
    test "create" do
      user = insert(:user)

      assert {:ok, %Core.Model.Factor{} = factor} =
               AuthX.create_apikey(user, %{
                 "contact" => "norbert@domain.com"
               })

      assert factor.type === :apikey
      assert is_binary(factor.value) === true
      assert String.length(factor.value)
      assert factor
    end
  end
end
