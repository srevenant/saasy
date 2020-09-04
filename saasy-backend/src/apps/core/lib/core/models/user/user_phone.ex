defmodule Core.Model.UserPhone do
  @moduledoc """
  Schema for representing and working with a UserPhone.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_phones" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    field(:number, :string)
    field(:primary, :boolean, default: false)
    field(:verified, :boolean, default: false)
    timestamps()
  end

  @required_fields [:user_id, :number]
  @update_allowed_fields [:number, :primary, :verified]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
  end

  @doc """
  Build a changeset for creating a new UserPhone.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a UserPhone.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
