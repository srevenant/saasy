defmodule Core.Model.User do
  @moduledoc """
  Schema for representing and working with a User.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient
  #  use Core.Model.{Factor} # App, Client, Token}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    belongs_to(:tenant, Tenant, type: :binary_id, foreign_key: :tenant_id)
    field(:name, :string)
    has_one(:handle, UserHandle, on_delete: :delete_all)
    has_many(:emails, UserEmail, on_delete: :delete_all)
    has_many(:phones, UserPhone, on_delete: :delete_all)
    has_many(:data, UserData, on_delete: :delete_all)
    field(:settings, :map, default: %{})
    field(:last_seen, :utc_datetime)
    has_many(:factors, Factor, on_delete: :delete_all)
    has_many(:accesses, Access, on_delete: :delete_all)
    has_many(:files, Upload.File, on_delete: :delete_all, foreign_key: :ref_id)
    field(:authz, Ecto.MapSet, default: %MapSet{}, virtual: true)
    field(:type, UserTypesEnum, default: :unknown)
    timestamps()
  end

  @required_fields [:tenant_id]
  @update_allowed_fields [:settings, :name, :last_seen, :type]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
    # users_tenant_id_fkey
    |> foreign_key_constraint(:tenant_id)
  end

  @doc """
  Build a changeset for creating a new User.
  """
  # TODO: remove nil from settings: attrs = :maps.filter(fn _, v -> !is_nil(v) end, attrs)
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a User.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
