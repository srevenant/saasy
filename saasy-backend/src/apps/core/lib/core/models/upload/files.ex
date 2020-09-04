defmodule Core.Model.Upload.Files do
  alias Core.Model.Upload
  use Core.Context
  use Core.Model.CollectionUuid, model: Upload.File

  @s3_bucket :uploads

  ##############################################################################
  def cleanup_invalid() do
    _cutoff = Timex.now()

    # Repo.delete_all(
    #   from(
    #     u in UploadFile,
    #       where: u.valid == false and u.updated_at < ^cutoff))

    # UploadFiles.all!(valid: false)
    # |> Enum.each(fn upload ->
    #   if Timex.diff(cutoff, upload.updated_at, :seconds) > 900 do
    #     delete_upload(upload)
    #   end
    # end)
    #### problem for another day:
    ### {:http_error, 403, %{body: "<?xml version="1.0" encoding="UTF-8"?>n<Error><Code>AccessDenied</Code><Message>Access Denied</Message><RequestId>BH5V1VDT9R3V0XFY</RequestId><HostId>yIeBVzGTDHyDQvd599d7PEkRhCSC60KI5m7JEafOxwCkTkYZ1k6UdWsfxSyx188nkyWR4od9yI0=</HostId></Error>", headers: [{"x-amz-request-id", "BH5V1VDT9R3V0XFY"}, {"x-amz-id-2", "yIeBVzGTDHyDQvd599d7PEkRhCSC60KI5m7JEafOxwCkTkYZ1k6UdWsfxSyx188nkyWR4od9yI0="}, {"Content-Type", "application/xml"}, {"Transfer-Encoding", "chunked"}, {"Date", "Sun, 09 Aug 2020 21:12:53 GMT"}, {"Server", "AmazonS3"}], status_code: 403}}
  end

  ##############################################################################
  # don't delete it from s3
  def delete_file(%Upload.File{meta: %{"default" => "true"}} = file) do
    delete(file)
  end

  def delete_file(%Upload.File{} = file) do
    case Core.Integration.S3.delete_object(file.path, @s3_bucket) do
      {:error, msg} ->
        IO.inspect({"CANNOT DELETE S3 FILE", msg})

      {:ok, _} ->
        delete(file)
    end
  end

  def delete_file(%{type: type, id: id}) do
    with {:ok, file} <- one(id: id) do
      delete_file(file)
      update_ref(file)
      {:ok, file}
    else
      _ ->
        {:error, "cannot find #{type} upload with id=#{id}"}
    end
  end

  ##############################################################################
  defp clean_args(args), do: args

  # UPDATE an existing record
  def upsert_file(%{id: id} = args) do
    with {:ok, record} <- one(id: id) do
      update(record, clean_args(args))
      |> upsert_gen_url(args)
    end
  end

  # CREATE a new record -- randomly generate path
  # ADD ref 'domain' to args (Project)
  def upsert_file(args) do
    path = Core.Integration.S3.gen_rand_name(@s3_bucket)

    result = create(clean_args(args) |> Map.put(:path, path))
    update_ref(args)
    upsert_gen_url(result, args)
  end

  def update_ref(args) do
    case args do
      # %{meta: %{"ref" => "project"}} ->
      #   Projects.update_states(args.ref_id)

      _ ->
        :ok
    end
  end

  ##############################################################################
  def upsert_gen_url({:ok, %Upload.File{path: path} = file}, %{gen_url: true}) do
    with {:ok, url} <- Core.Integration.S3.gen_download_url(path) do
      {:ok, %Upload.File{file | signed_url: url}}
    end
  end

  def upsert_gen_url(pass, _), do: pass
end
