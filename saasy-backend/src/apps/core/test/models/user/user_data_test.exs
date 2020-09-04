defmodule Core.UserDataTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest UserData
  doctest UserDatas

  describe "factory" do
    test "factory creates a valid instance" do
      assert %UserData{} = user_data = insert(:user_data)
      assert user_data.id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:user_data)
      changeset = UserData.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:user_data)
      assert %UserData{} = found = UserDatas.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:user_data)
      assert {:ok, user_data} = UserDatas.create(attrs)
      assert user_data.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      user_data = insert(:user_data)
      assert {:ok, deleted} = UserDatas.delete(user_data)
      assert deleted.id == user_data.id
    end
  end

  describe "has_one journey" do
    test "has-one journey" do
      user = insert(:user)
      actor = insert(:journey_actor, user: user)
      assert actor.user_id == user.id
      {:ok, user2} = Users.preload(user, :journey_actor)
      assert user2.journey_actor.id == actor.id
    end
  end
end
