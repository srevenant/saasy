defmodule WebSvc.Resolvers.UploadFileResolver do
  @moduledoc """
  """
  import Web.Absinthe
  use Core.ContextClient
  require Logger

  ##############################################################################
  # with valid it's just marking done or not
  ####
  #### TODO: wrap user_id into object and limit to your own stuff
  ####
  def mutate_upsert_upload_file(%{file: file}, info) do
    with_current_user(info, "upsertUploadFile", fn user ->
      # insert this user on create
      file =
        with %{meta: meta} <- file do
          Map.put(file, :meta, Poison.decode!(meta))
        end

      case file do
        %{id: _} -> file
        _ -> Map.put(file, :user_id, user.id)
      end
      |> Upload.Files.upsert_file()
    end)
  end

  ##############################################################################
  def mutate_delete_upload_file(%{file: file}, info) do
    with_current_user(info, "deleteUploadFile", fn _user ->
      Upload.Files.delete_file(file)
    end)
  end
end
