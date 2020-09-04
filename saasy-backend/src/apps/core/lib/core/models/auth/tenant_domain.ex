defmodule Core.Model.TenantDomain do
  @moduledoc """
  Record of a tenant_domain.  These should get created implicitly as we map new tenant_domain domains, but we can add info to them
  """

  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "saasy_tenant_domains" do
    field(:name, :string)
    belongs_to(:tenant, Tenant, type: :binary_id, foreign_key: :tenant_id)
    timestamps()
  end

  def validate(chgset) do
    chgset
    |> validate_required(:name)
    |> validate_length(:name, min: 2)
    |> validate_format(:name, ~r/^[a-z0-9\.-]+$/i)
    |> unique_constraint(:name, name: :tenant_domains_name_index)
  end

  @doc """
  Build a changeset for creating a new record.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:name, :tenant_id])
    |> validate
  end

  @doc """
  Changeset for performing updates to a record.
  """
  def changeset(tenant_domain, attrs) do
    tenant_domain
    |> cast(attrs, [:name, :tenant_id])
    |> validate
  end

  use Core.Model.CollectionModel
end
