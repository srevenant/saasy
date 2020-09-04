defmodule Core.TenantTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest Tenant
  doctest Tenants

  #  describe "factory" do
  #    test "factory creates a valid instance" do
  #      assert %Tenant{} = tenant = insert(:tenant)
  #      assert tenant.id != nil
  #    end
  #  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:tenant)
      changeset = Tenant.build(params)
      assert changeset.valid?
    end
  end

  describe "one!/1" do
    test "loads tenant" do
      c = insert(:tenant, code: "new-name")
      assert %Tenant{} = found = Tenants.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:tenant)
      assert {:ok, tenant} = Tenants.create(attrs)
      assert tenant.id != nil
    end

    test "cannot insert duplicate tenant" do
      attrs = params_for(:tenant, code: "boop")
      assert {:ok, tenant} = Tenants.create(attrs)
      assert tenant.id != nil
      assert {:error, chgs} = Tenants.create(attrs)
      assert {"has already been taken", _} = Keyword.get(chgs.errors, :code)
      assert tenant.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      tenant = insert(:tenant)
      assert {:ok, deleted} = Tenants.delete(tenant)
      assert deleted.id == tenant.id
    end
  end
end
