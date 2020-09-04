defmodule Core.UserTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest User
  doctest Users

  describe "factory" do
    test "factory creates a valid instance" do
      assert %User{} = user = insert(:user)
      assert user.id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:user)
      changeset = User.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:user)
      assert %User{} = found = Users.one!(tenant_id: c.tenant_id, id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:user)
      assert {:ok, user} = Users.create(attrs)
      assert user.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      user = insert(:user)
      assert {:ok, deleted} = Users.delete(user)
      assert deleted.id == user.id
    end
  end
end
