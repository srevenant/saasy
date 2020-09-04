defmodule Core.Model.RoleMap do
  @moduledoc """
  Schema for representing and working with a RoleMap.
  """
  use Ecto.Schema
  import Ecto.Changeset
  use Core.ContextClient

  schema "saasy_role_maps" do
    belongs_to(:action, Action, foreign_key: :action_id)
    belongs_to(:role, Role, foreign_key: :role_id)
  end

  @required_fields [:action_id, :role_id]
  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
  end

  @doc """
  Build a changeset for creating a new RoleMap.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> unique_constraint(:action_id, name: :role_maps_role_id_action_id_index)
    |> validate_required(@required_fields)
  end

  @doc """
  Changeset for performing updates to a RoleMap.
  """
  def changeset(item, params) do
    item
    |> cast(params, @required_fields)
    |> unique_constraint(:action_id, name: :role_maps_role_id_action_id_index)
    |> validate_required(@required_fields)
  end

  use Core.Model.CollectionModel
end
