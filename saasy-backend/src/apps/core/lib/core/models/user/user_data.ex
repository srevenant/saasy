defmodule Core.Model.UserData do
  @moduledoc """
  Schema for representing and working with a UserData.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_datas" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    field(:type, UserDataTypesEnum)
    field(:value, :map)
    timestamps()
  end

  @required_fields [:user_id, :type, :value]
  @update_allowed_fields [:value]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
    |> unique_constraint(:type, name: :user_datas_user_id_type_index)
  end

  @doc """
  Build a changeset for creating a new UserData.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a UserData.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
