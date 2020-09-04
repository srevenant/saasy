defmodule Core.Repo.Migrations.SaasyMigration do
  @moduledoc """
  """
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION citext", "DROP EXTENSION citext")

    ############################################################################
    create table(:saasy_tenants, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:code, :string, null: false)
      add(:settings, :map)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:saasy_tenants, [:code], name: :tenants_code_index))

    create table(:saasy_tenant_domains, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:tenant_id, references(:saasy_tenants, on_delete: :delete_all, type: :uuid))
      timestamps()
    end

    create(unique_index(:saasy_tenant_domains, [:name], name: :tenant_domains_name_index))

    ############################################################################
    # create table(:saasy_setting_groups, primary_key: false) do
    #   add(:id, :uuid, primary_key: true)
    #   add(:tenant_id, references(:saasy_tenants, on_delete: :delete_all, type: :uuid))
    #   add(:name, :citext, null: false)
    #   add(:help, :citext)
    #   timestamps()
    # end
    #
    # create(unique_index(:saasy_setting_groups, [:tenant_id, :name], name: :setting_group_name))
    #
    # create table(:saasy_setting_globals, primary_key: false) do
    #   add(:id, :uuid, primary_key: true)
    #   add(:group_id, references(:saasy_setting_groups, on_delete: :delete_all, type: :uuid))
    #   add(:name, :citext, null: false)
    #   add(:help, :text)
    #   add(:value, :map)
    #   timestamps()
    # end
    #
    # create(index(:saasy_setting_globals, [:group_id]))
    # create(unique_index(:saasy_setting_globals, [:group_id, :name], name: :setting_global_name))

    ############################################################################
    # This should be a write ONCE table, no updates.
    # add a second table to reference this table, as needed for ledger activity
    # create table(:saasy_usages, primary_key: false) do
    #   add(:id, :uuid, primary_key: true)
    #   # loose coupling is okay; references(:tenants, on_delete: :delete_all, type: :uuid))
    #   add(:tenant_id, :uuid)
    #   # probably references(:user)?
    #   add(:user, :string)
    #   add(:start, :integer, null: false)
    #   add(:end, :integer)
    #   add(:source, :string, null: false)
    #   add(:metric, :text)
    #   add(:cost, :integer, default: 0)
    #   add(:memo, :text)
    #   timestamps()
    # end
    #
    # create(index(:saasy_usages, [:tenant_id]))
    # create(index(:saasy_usages, [:tenant_id, :start, :end]))

    ############################################################################
    # keep users at the base -- it's well enough known not to be confused
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:tenant_id, references(:saasy_tenants, on_delete: :delete_all, type: :uuid))
      add(:name, :string)
      add(:settings, :map)
      add(:last_seen, :utc_datetime)
      add(:type, :integer)
      timestamps()
    end

    ############################################################################
    # separate username so it can be left blank and not have unique constraint problems
    create table(:user_handles, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      # transitive dependency, but used for uniqueness w/tenant
      add(:tenant_id, :uuid, null: false)
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false)
      add(:handle, :citext, null: false)
      timestamps()
    end

    create(unique_index(:user_handles, [:tenant_id, :handle], name: :users_tenant_handle_index))

    ############################################################################
    # TODO: Mapping table for many users to one email
    create table(:user_emails, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      # transitive dependency, but used for uniqueness w/tenant
      add(:tenant_id, :uuid, null: false)
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid))
      add(:address, :citext)
      add(:primary, :boolean)
      add(:verified, :boolean)
      timestamps()
    end

    create(index(:user_emails, [:user_id], using: :hash))
    create(unique_index(:user_emails, [:tenant_id, :address]))

    ############################################################################
    create table(:user_phones, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid))
      add(:number, :string)
      add(:primary, :boolean)
      add(:verified, :boolean)
      timestamps()
    end

    create(index(:user_phones, [:user_id], using: :hash))

    ############################################################################
    create table(:user_datas, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid, null: true))
      add(:type, :integer, default: 0)
      add(:value, :map, default: %{})
      timestamps()
    end

    create(index(:user_datas, [:user_id]))
    create(unique_index(:user_datas, [:user_id, :type]))

    ############################################################################
    create table(:saasy_factors, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid))
      add(:type, :integer, null: false)
      add(:fedtype, :integer, null: false)
      add(:name, :string)
      add(:value, :string)
      add(:expires_at, :integer)
      add(:details, :map)
      add(:hash, :text)
      timestamps()
    end

    create(index(:saasy_factors, [:user_id], using: :hash))
    create(index(:saasy_factors, [:user_id, :type]))
    create(index(:saasy_factors, [:user_id, :type, :name]))
    create(index(:saasy_factors, [:user_id, :type, :expires_at]))

    ############################################################################
    # future: multi-map this (many:many)
    #    create table(:addresses, primary_key: false) do
    #      add(:id, :uuid, primary_key: true)
    #      timestamps()
    #    end
    #    create(index(:emails, [:user_id], using: :hash))

    ############################################################################
    # action, role, role_map, accesses
    # action=free-form token for thing to be done, i.e. 'make-users'
    # role=a named grouping of actions (via map table)
    # role_map= mapping of actions to role
    # accesses= mapping of users to roles

    # az = authz / authorization
    create table(:saasy_actions) do
      add(:name, :citext)
      add(:domain, :string)
      add(:action, :string)
      add(:description, :text)
    end

    create(unique_index(:saasy_actions, [:name]))
    create(index(:saasy_actions, [:domain]))

    create table(:saasy_roles) do
      add(:name, :string)
      add(:subscription, :boolean, default: false)
      add(:description, :text)
    end

    create(unique_index(:saasy_roles, [:name]))

    create table(:saasy_role_maps) do
      add(:role_id, references(:saasy_roles, on_delete: :delete_all))
      add(:action_id, references(:saasy_actions, on_delete: :delete_all))
    end

    create(
      unique_index(:saasy_role_maps, [:role_id, :action_id],
        name: :role_maps_role_id_action_id_index
      )
    )

    create table(:saasy_accesses) do
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid))
      add(:role_id, references(:saasy_roles, on_delete: :delete_all))
    end

    create(
      unique_index(:saasy_accesses, [:user_id, :role_id], name: :accesses_user_id_role_id_index)
    )

    ############################################################################
    # really should be in base, but this keeps it from erroring
    alter table(:saasy_tenants) do
      add(:owner_id, references(:users, type: :uuid))
    end

    ############################################################################
    create table(:user_codes) do
      add(:user_id, references(:users, on_delete: :delete_all, type: :uuid))
      add(:type, :integer)
      add(:code, :citext)
      add(:meta, :map)

      timestamps()
    end

    create(unique_index(:user_codes, [:user_id, :type, :code]))
  end
end
