defmodule Core.Model.FactorTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest Factor, import: true
  doctest Factors, import: true

  describe "factory" do
    test "factory creates a basic factor" do
      assert %Factor{} = insert(:factor)
    end

    test "factory creates a password hashed factor" do
      assert %Factor{} = insert(:hashpass_factor)
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_with_assocs(:factor)
      changeset = Factor.build(params)
      assert changeset.valid?
    end

    test "requires secret and expires_at" do
      params = params_for(:factor, expires_at: nil)
      changeset = Factor.build(params)
      assert changeset.valid? == false
      assert {"can't be blank", _} = Keyword.get(changeset.errors, :expires_at)
    end

    test "hashed password factor" do
      assert %Factor{} = factor = insert(:hashpass_factor)
      assert not is_nil(factor.hash) and is_binary(factor.hash)
    end
  end

  describe "relationships" do
    test "to user" do
      factor = insert(:factor)
      attrs = params_for(:factor, type: :password, user_id: factor.user_id)
      assert {:ok, _factor2} = Factors.create(attrs)
      all = Factors.all!(user_id: factor.user_id)
      assert length(all) == 2

      user =
        Users.one!(id: factor.user_id)
        |> Factors.preloaded_with(factor.type)

      assert length(user.factors) == 1

      assert Enum.find(user.factors, fn a ->
               a.type == factor.type
             end)
    end
  end

  describe "create_apikey" do
    test "new apikey" do
      assert {:ok, user} = Users.preload(insert(:user), :tenant)
      assert {:ok, tenant} = Tenants.preload(Tenants.one!(user.tenant.id), :domains)
      #      assert {:ok, apikey} = Factors.create_apikey(List.first(tenant.domains).name, user)
      #      assert is_binary(apikey.value)
      #      assert String.length(apikey.value) > 1
    end
  end
end
