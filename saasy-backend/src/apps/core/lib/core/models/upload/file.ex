defmodule Core.Model.Upload.File do
  @moduledoc """
  Schema template for mapping to uploaded files.
  """
  use Ecto.Schema
  import Ecto.Changeset
  use Core.ContextClient

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "upload_files" do
    field(:ref_id, :binary_id)
    belongs_to(:user, User, type: :binary_id)
    field(:valid, :boolean, default: false)
    field(:path, :string)
    field(:meta, :map, default: %{})
    field(:signed_url, :string, virtual: true)
    field(:type, UploadFileTypeEnum)
    timestamps()
  end

  @required_fields [:ref_id, :path, :user_id, :type]
  @update_allowed_fields [:meta, :valid]
  @create_allowed_fields @required_fields ++ @update_allowed_fields

  def validate(chgset) do
    chgset
    |> validate_required(@required_fields)

    # |> unique_constraint(:path, name: @index_name)
  end

  @doc """
  Build a changeset for creating a new PropertyPhoto.
  """
  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @create_allowed_fields)
    |> validate
  end

  @doc """
  Changeset for performing updates to a PropertyPhoto.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, @update_allowed_fields)
    |> validate
  end

  use Core.Model.CollectionModel
end
