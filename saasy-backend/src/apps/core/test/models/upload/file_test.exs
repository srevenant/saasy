defmodule Core.Upload.FileTest do
  use Core.Case, async: true
  use Core.ContextClient

  doctest Upload.File, import: true
  doctest Upload.Files, import: true

  describe "factory" do
    test "factory creates a valid instance" do
      assert %Upload.File{} = upload_file = insert(:upload_file)
      assert upload_file.id != nil
    end
  end

  describe "build/1" do
    test "build when valid" do
      params = params_for(:upload_file)
      changeset = Upload.File.build(params)
      assert changeset.valid?
    end
  end

  describe "get/1" do
    test "loads saved transactions as expected" do
      c = insert(:upload_file)
      assert %Upload.File{} = found = Upload.Files.one!(id: c.id)
      assert found.id == c.id
    end
  end

  describe "create/1" do
    test "inserts a valid record" do
      attrs = params_for(:upload_file)
      assert {:ok, upload_file} = Upload.Files.create(attrs)
      assert upload_file.id != nil
    end
  end

  describe "delete/1" do
    test "deletes record" do
      upload_file = insert(:upload_file)
      assert {:ok, deleted} = Upload.Files.delete(upload_file)
      assert deleted.id == upload_file.id
    end
  end
end
