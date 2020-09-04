defmodule Core.UserEmailTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest UserEmail
  doctest UserEmails

  describe "factory" do
    test "factory creates a valid instance" do
      assert %UserEmail{} = email = insert(:email)
      assert email.id != nil
      assert email.user_id != nil
      assert String.length(email.address) > 0
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_with_assocs(:email)
      changeset = UserEmail.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:email)
      assert %UserEmail{} = found = UserEmails.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_with_assocs(:email)
      assert {:ok, email} = UserEmails.create(attrs)
      assert email.id != nil
    end

    test "inserts multiple records" do
      email1 = insert(:email)
      email2 = insert(:email, user: email1.user)
      assert email1.user_id == email2.user_id
    end

    test "sets verified" do
      email = insert(:email)
      assert email.verified == false
      {:ok, updated} = UserEmails.update(email, %{verified: true})
      assert updated.verified == true
    end

    test "sets primary" do
      email = insert(:email)
      assert email.primary == false
      {:ok, updated} = UserEmails.update(email, %{primary: true})
      assert updated.primary == true
    end

    test "bad records are properly denied" do
      attrs = params_with_assocs(:email)
      assert {:error, chgs} = UserEmails.create(Map.put(attrs, :address, ""))
      assert {"can't be blank", _} = Keyword.get(chgs.errors, :address)
      assert {:error, chgs} = UserEmails.create(Map.put(attrs, :address, "hi"))
      assert {"needs to be a valid email address", _} = Keyword.get(chgs.errors, :address)
    end
  end

  describe "delete/1" do
    test "deletes record" do
      email = insert(:email)
      assert {:ok, deleted} = UserEmails.delete(email)
      assert deleted.id == email.id
    end
  end
end
