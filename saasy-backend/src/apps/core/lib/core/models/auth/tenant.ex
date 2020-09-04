defmodule Core.Model.Tenant do
  @moduledoc """
  Record of a tenant.  These should get created implicitly as we map new tenant_domain domains, but we can add info to them
  """

  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "saasy_tenants" do
    field(:code, :string)
    field(:name, :string)
    field(:settings, :map)
    belongs_to(:owner, User, type: :binary_id)
    has_many(:domains, TenantDomain)
    field(:domain, :string, virtual: true)
    timestamps()
  end

  @required_fields [:code]
  @update_allowed_fields [:name, :code, :settings, :owner_id]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
    |> validate_length(:code, min: 2)
    |> validate_format(:code, ~r/^[a-z0-9\.-]+$/i)
    |> unique_constraint(:code, name: :tenants_code_index)
  end

  @doc """
  Build a changeset for creating a new record.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a record.
  """
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
