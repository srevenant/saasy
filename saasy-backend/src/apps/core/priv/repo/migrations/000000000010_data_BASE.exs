defmodule Core.Repo.Migrations.DataMigration do
  @moduledoc """
  """
  use Ecto.Migration

  def change do
    # what we really need is a big-data solution

    ############################################################################
    create(table(:summary)) do
      add(:ref_id, :uuid)
      add(:type, :integer)
      add(:value, :map)
      add(:latest, :boolean)
      timestamps()
    end

    create(index(:summary, [:type, :latest]))

    ############################################################################
    create(table(:summary_users)) do
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false)
      add(:type, :integer)
      add(:value, :map)
      timestamps()
    end

    create(unique_index(:summary_users, [:user_id, :type]))
  end
end
