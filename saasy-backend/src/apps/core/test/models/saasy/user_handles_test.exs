defmodule Core.UserHandlesTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest UserHandle
  doctest UserHandles

  describe "factory" do
    test "factory creates a valid instance" do
      assert %UserHandle{} = handle = insert(:handle)
      assert handle.id != nil
      assert handle.user_id != nil
      assert handle.tenant_id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_with_assocs(:handle)
      changeset = UserHandle.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:handle)
      assert %UserHandle{} = found = UserHandles.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_with_assocs(:handle)
      assert {:ok, handle} = UserHandles.create(attrs)
      assert handle.id != nil
    end

    test "cannot insert duplicate per tenant" do
      attrs = params_with_assocs(:handle)
      assert {:ok, handle} = UserHandles.create(attrs)
      assert handle.id != nil
      assert {:error, chgs} = UserHandles.create(attrs)
      assert {"has already been taken", _} = Keyword.get(chgs.errors, :handle)
      assert handle.id != nil
      newtenant = insert(:tenant)
      attrs = Map.put(attrs, :tenant_id, newtenant.id)
      assert {:ok, handle} = UserHandles.create(attrs)
      assert handle.id != nil
    end

    test "bad records are properly denied" do
      attrs = params_with_assocs(:handle)
      assert {:error, chgs} = UserHandles.create(Map.put(attrs, :handle, "hi"))
      assert {"should be at least %{count} character(s)", _} = Keyword.get(chgs.errors, :handle)

      assert {:error, chgs} =
               UserHandles.create(
                 Map.put(attrs, :handle, "verylonghandlethatshouldbetoolongover32chars")
               )

      assert {"should be at most %{count} character(s)", _} = Keyword.get(chgs.errors, :handle)
      assert {:error, chgs} = UserHandles.create(Map.put(attrs, :handle, "handle with bad chars"))
      assert {"may only have characters: a-z0-9+-", _} = Keyword.get(chgs.errors, :handle)
    end
  end

  describe "delete/1" do
    test "deletes record" do
      handle = insert(:handle)
      assert {:ok, deleted} = UserHandles.delete(handle)
      assert deleted.id == handle.id
    end
  end
end
