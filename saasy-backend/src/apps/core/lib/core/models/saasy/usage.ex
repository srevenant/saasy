defmodule Core.Model.Usage do
  @moduledoc """
  Schema for representing and working with a Usage.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "saasy_usages" do
    # belongs_to(:tenant, Tenant, type: :binary_id, foreign_key: :tenant_id)
    # loose coupling is okay
    field(:tenant_id, :binary_id)
    field(:user, :string)
    field(:start, :integer)
    field(:end, :integer)
    field(:source, :string)
    field(:metric, :string)
    field(:cost, :integer)
    field(:memo, :string)
    timestamps()
  end

  @required_fields [:tenant_id, :start, :source]
  @update_allowed_fields [:user, :end, :metric, :cost, :memo]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate_required(@required_fields)
  end

  # we don't do changes
  def changeset(_, _), do: nil

  use Core.Model.CollectionModel
end
