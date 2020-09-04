defmodule Core.UserPhoneTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest UserPhone
  doctest UserPhones

  describe "factory" do
    test "factory creates a valid instance" do
      assert %UserPhone{} = phone = insert(:phone)
      assert phone.id != nil
      assert phone.user_id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_with_assocs(:phone)
      changeset = UserPhone.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:phone)
      assert %UserPhone{} = found = UserPhones.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_with_assocs(:phone)
      assert {:ok, phone} = UserPhones.create(attrs)
      assert phone.id != nil
    end

    test "inserts multiple records" do
      phone1 = insert(:phone)
      phone2 = insert(:phone, user: phone1.user)
      assert phone1.user_id == phone2.user_id
    end

    test "sets verified" do
      phone = insert(:phone)
      assert phone.verified == false
      {:ok, updated} = UserPhones.update(phone, %{verified: true})
      assert updated.verified == true
    end

    test "sets primary" do
      phone = insert(:phone)
      assert phone.primary == false
      {:ok, updated} = UserPhones.update(phone, %{primary: true})
      assert updated.primary == true
    end
  end

  describe "delete/1" do
    test "deletes record" do
      phone = insert(:phone)
      assert {:ok, deleted} = UserPhones.delete(phone)
      assert deleted.id == phone.id
    end
  end
end
