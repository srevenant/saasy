defmodule Core.Model.Factor do
  @moduledoc """
  Schema for representing and working with an AuthFactor.

  Notes (BJG)
    - any authentication which ages more than ~10 minutes is frankly no better
      than identity.  figure out how to add a combination of 'type', 'trust',
      which includes 'age'...
  """
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  import Ecto.Changeset
  alias Core.Model.User
  @derive {Poison.Encoder, only: [:name, :expires_at, :value, :details]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "saasy_factors" do
    # identity vs authentication
    field(:type, FactorTypeEnum)
    field(:fedtype, FactorFederatedTypeEnum, default: :none)
    field(:name, :string)
    field(:expires_at, :integer)
    field(:value, :string)
    field(:details, :map)
    # we put these back as passwords
    field(:password, :string, virtual: true)
    # we don't store these again
    field(:secret, :string, virtual: true)
    field(:hash, :string)
    timestamps()
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
  end

  @required_fields [:type, :expires_at, :user_id]

  @create_allowed_fields @required_fields ++ [:value, :details, :hash, :password, :name, :fedtype]

  @doc """
  Build a changeset for creating a new AuthFactor.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate_required(@required_fields)
    |> hash_password

    # TODO: Expires limits
  end

  # TODO: Should not be changing factors.... we don't do changes
  #  def changeset(_, _), do: nil

  @doc """
  Changeset for performing updates to a Phone.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @create_allowed_fields)
    |> validate_required(@required_fields)
  end

  def hash_password(changeset = %Ecto.Changeset{valid?: true, changes: %{password: pass}}) do
    put_change(changeset, :hash, Utils.Hash.password(pass))
    # consider: delete password: token?
  end

  def hash_password(changeset), do: changeset

  use Core.Model.CollectionModel
end
