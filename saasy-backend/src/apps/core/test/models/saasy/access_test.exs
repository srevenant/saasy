defmodule Core.AccessTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest Access
  doctest Accesses

  describe "factory" do
    test "factory creates a valid instance" do
      assert %Access{} = access = insert(:access)
      assert access.user_id != nil
      assert access.role_id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:access)
      changeset = Access.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:access)
      assert %Access{} = found = Accesses.one!(user_id: c.user_id, role_id: c.role_id)
      assert found.user_id == c.user_id
      assert found.role_id == c.role_id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:access)
      assert {:ok, access} = Accesses.create(attrs)
      assert access.user_id != nil
    end
  end
end
