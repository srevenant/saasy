defmodule Core.Model.SummaryUser do
  @moduledoc """
  Schema for representing and working with a SummaryUser.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  schema "summary_users" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    field(:type, SummaryUserTypeEnum)
    field(:value, :map)
    timestamps()
  end

  @required_fields [:user_id, :type, :value]
  @update_allowed_fields [:value]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
  end

  @doc """
  Build a changeset for creating a new SummaryUser.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> unique_constraint(:type, name: :summary_users_type_index)
    |> validate
  end

  @doc """
  Changeset for performing updates to a SummaryUser.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
