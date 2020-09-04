defmodule Core.TenantDomainDomainsTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest TenantDomain
  doctest TenantDomains

  describe "factory" do
    test "factory creates a valid instance" do
      assert %TenantDomain{} = tenant_domain = insert(:tenant_domain)
      assert tenant_domain.id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:tenant_domain)
      changeset = TenantDomain.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads tenant_domain" do
      c = insert(:tenant_domain)
      assert %TenantDomain{} = found = TenantDomains.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:tenant_domain)
      assert {:ok, tenant_domain} = TenantDomains.create(attrs)
      assert tenant_domain.id != nil
    end

    test "cannot insert duplicate tenant_domain" do
      attrs = params_for(:tenant_domain, name: "boop")
      assert {:ok, tenant_domain} = TenantDomains.create(attrs)
      assert tenant_domain.id != nil
      assert {:error, chgs} = TenantDomains.create(attrs)
      assert {"has already been taken", _} = Keyword.get(chgs.errors, :name)
      assert tenant_domain.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      tenant_domain = insert(:tenant_domain)
      assert {:ok, deleted} = TenantDomains.delete(tenant_domain)
      assert deleted.id == tenant_domain.id
    end
  end
end
