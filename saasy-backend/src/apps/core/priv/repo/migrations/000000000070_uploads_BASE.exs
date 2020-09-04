defmodule Core.Repo.Migrations.UploadFileMigration do
  @moduledoc """
  """
  use Ecto.Migration

  def change do
    create table(:upload_files, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:type, :integer)
      add(:ref_id, :uuid, null: false)
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false)
      add(:path, :text, null: false)
      add(:valid, :boolean, null: false, default: false)
      add(:meta, :map, null: false)
      timestamps()
    end

    create(index(:upload_files, [:ref_id]))
  end
end
