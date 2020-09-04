defmodule Core.Model.Role do
  @moduledoc """
  Schema for representing and working with a Access.
  """
  use Ecto.Schema
  import Ecto.Changeset
  use Core.ContextClient

  schema "saasy_roles" do
    field(:name, Ecto.Atom)
    # field(:subscription, :boolean)
    field(:description, :string)
  end

  @required_fields [:name, :description]
  @update_allowed_fields [:description, :name]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
  end

  @doc """
  Build a changeset for creating a new Access.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a Access.
  """
  def changeset(item, params) do
    item
    |> cast(params, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
