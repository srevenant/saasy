defmodule Core.Model.Action do
  @moduledoc """
  Schema for representing and working with a Access.
  """
  use Ecto.Schema
  import Ecto.Changeset
  use Core.ContextClient

  schema "saasy_actions" do
    field(:name, Ecto.Atom)
    field(:domain, Ecto.Atom)
    field(:action, Ecto.Atom)
    field(:description, :string)
  end

  @required_fields [:name, :description, :domain, :action]
  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
  end

  @doc """
  Build a changeset for creating a new Access.
  """
  # TODO: change so :name is not passed in on change, it's built from action+domain
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  @doc """
  Changeset for performing updates to a Access.
  """
  def changeset(item, params) do
    item
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  use Core.Model.CollectionModel
end
