defmodule Core.Model.UserCode do
  @moduledoc """
  Schema for representing and working with a UserCode.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  schema "user_codes" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    field(:type, UserCodeTypesEnum)
    field(:code, :string)
    field(:meta, :map, default: %{})
    field(:expires, :utc_datetime)
    timestamps()
  end

  @required_fields [:user_id, :code, :type, :expires]
  @update_allowed_fields [:meta]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id, name: :user_codes_user_id_fkey)
  end

  @doc """
  Build a changeset for creating a new UserCode.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a UserCode.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
