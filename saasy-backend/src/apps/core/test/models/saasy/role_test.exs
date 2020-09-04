defmodule Core.RoleTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest Role
  doctest Roles

  describe "factory" do
    test "factory creates a valid instance" do
      assert %Role{} = role = insert(:role)
      assert role.id != nil
      assert role.name != nil
      assert role.description != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:role)
      changeset = Role.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:role)
      assert %Role{} = found = Roles.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:role)
      assert {:ok, role} = Roles.create(attrs)
      assert role.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      role = insert(:role)
      assert {:ok, deleted} = Roles.delete(role)
      assert deleted.id == role.id
    end
  end
end
