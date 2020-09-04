defmodule Core.Model.Summary do
  @moduledoc """
  Schema for representing and working with a Summary.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  schema "summary" do
    field(:latest, :boolean, default: true)
    field(:type, SummaryTypeEnum)
    field(:value, :map)
    timestamps()
  end

  @required_fields [:type, :value]
  @update_allowed_fields [:value, :latest]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
  end

  @doc """
  Build a changeset for creating a new Summary.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a Summary.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
