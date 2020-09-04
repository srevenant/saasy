defmodule Core.Model.Access do
  @moduledoc """
  Schema for representing and working with a Access.
  """
  use Ecto.Schema
  import Ecto.Changeset
  use Core.ContextClient

  schema "saasy_accesses" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    belongs_to(:role, Role, foreign_key: :role_id)
  end

  @required_fields [:user_id, :role_id]
  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
    |> unique_constraint(:role, name: :accesses_user_id_role_id_index)
  end

  @doc """
  Build a changeset for creating a new Access.
  """
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
