defmodule WebSvc.Schema.UploadFileSchema do
  use Absinthe.Schema.Notation
  use Timex
  alias WebSvc.Resolvers.UploadFileResolver
  require Logger

  ##############################################################################
  scalar :upload_type do
    serialize(&Atom.to_string/1)
    parse(&UploadFileTypeEnum.cast/1)
  end

  # differs from UploadFile by having slightly less info
  object :file do
    field(:id, non_null(:string))
    field(:valid, non_null(:boolean))
    field(:path, non_null(:string))
    field(:type, non_null(:upload_type))
    field(:meta, :integer)
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  object :upload_file do
    field(:id, non_null(:string))
    field(:type, non_null(:upload_type))
    field(:ref_id, non_null(:string))
    field(:user_id, non_null(:string))
    field(:valid, non_null(:boolean))
    field(:path, non_null(:string))
    field(:meta, :integer)
    field(:signed_url, :string)
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  input_object :input_upload_file do
    field(:id, :string)
    field(:type, :string)
    field(:ref_id, :string)
    field(:valid, :boolean)
    field(:meta, :string)
    field(:gen_url, :boolean)
  end

  ##############################################################################
  object :upload_queries do
  end

  ##############################################################################
  object :upload_mutations do
    field :upsert_upload_file, :upload_file do
      arg(:file, non_null(:input_upload_file))
      resolve(&UploadFileResolver.mutate_upsert_upload_file/2)
    end

    field :delete_upload_file, :upload_file do
      arg(:file, non_null(:input_upload_file))
      resolve(&UploadFileResolver.mutate_delete_upload_file/2)
    end
  end
end
