defmodule Core.ActionTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest Action
  doctest Actions

  describe "factory" do
    test "factory creates a valid instance" do
      assert %Action{} = action = insert(:action)
      assert action.id != nil
      assert action.name != nil
      assert action.description != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:action)
      changeset = Action.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:action)
      assert %Action{} = found = Actions.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:action)
      assert {:ok, action} = Actions.create(attrs)
      assert action.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      action = insert(:action)
      assert {:ok, deleted} = Actions.delete(action)
      assert deleted.id == action.id
    end
  end
end
