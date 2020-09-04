defmodule Core.RoleMapTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest RoleMap
  doctest RoleMaps

  describe "factory" do
    test "factory creates a valid instance" do
      assert %RoleMap{} = role_map = insert(:role_map)
      assert role_map.action_id != nil
      assert role_map.role_id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:role_map)
      changeset = RoleMap.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:role_map)
      assert %RoleMap{} = found = RoleMaps.one!(action_id: c.action_id, role_id: c.role_id)
      assert found.action_id == c.action_id
      assert found.role_id == c.role_id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:role_map)
      assert {:ok, role_map} = RoleMaps.create(attrs)
      assert role_map.action_id != nil
    end
  end
end
