defmodule Core.Model.UserEmail do
  @moduledoc """
  Schema for representing and working with a UserEmail.
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  use Core.ContextClient

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_emails" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    field(:tenant_id, :binary_id)
    field(:address, :string)
    field(:primary, :boolean, default: false)
    field(:verified, :boolean, default: false)
    timestamps()
  end

  @required_fields [:user_id, :tenant_id, :address]
  @update_allowed_fields [:address, :primary, :verified]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)
    |> validate_format(:address, ~r/[a-z0-9+-]@[a-z0-9-]+\.[a-z0-9-]/i,
      message: "needs to be a valid email address"
    )
    |> unique_constraint(:address,
      name: :user_emails_tenant_id_address_index,
      message: "is already registered"
    )
  end

  @doc """
  Build a changeset for creating a new UserEmail.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a UserEmail.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
