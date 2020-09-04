defmodule Core.Model.UserHandle do
  @moduledoc """
  Schema for representing and working with a Handle.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  import Utils.EctoChangeset, only: [validate_rex: 4]
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_handles" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    field(:tenant_id, :binary_id)
    field(:handle, :string)
    timestamps()
  end

  @required_fields [:user_id, :tenant_id, :handle]
  @update_allowed_fields [:handle]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def map_indirect(params = %{user: user}) do
    params =
      if Map.get(params, :user_id) != user.id do
        Map.put(params, :user_id, user.id)
      end

    {:ok, user} = Users.preload(user, :tenant)

    params =
      if Map.get(params, :tenant_id) != user.tenant.id do
        Map.put(params, :tenant_id, user.tenant.id)
      end

    params
  end

  def map_indirect(params), do: params

  def validate(chgset) do
    handle = String.downcase(get_change(chgset, :handle))

    chgset
    |> validate_required(@required_fields)
    |> put_change(:handle, handle)
    |> validate_length(:handle, min: 4, max: 32)
    |> validate_rex(:handle, ~r/[^a-z0-9+-]+/,
      not: true,
      message: "may only have characters: a-z0-9+-"
    )
    |> validate_rex(:handle, ~r/(^-|-$)/,
      not: true,
      message: "may not start or end with a dash"
    )
    |> unique_constraint(:handle, name: :users_tenant_handle_index)
  end

  @doc """
  Build a changeset for creating a new Handle.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(map_indirect(params), @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a Handle.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
