defmodule Core.Integration.S3 do
  @moduledoc """
  Integration/wrappers with AWS s3

  https://hexdocs.pm/ex_aws_s3/ExAws.S3.html#summary

  """
  alias ExAws.S3
  require Logger

  @aws_default_cfg :uploads

  @doc ~S"""
  Pull from our extended config structure, allowing for different keys based
  on role.

  iex> cfg = get_cfg(:tmp)
  iex> cfg.bucket == "tmp"
  """
  def get_cfg(role) do
    ExAws.Config.new(:s3, Application.get_env(:core, :aws_s3) |> Keyword.get(role))
  end

  # to create the access config, create a unique IAM user just for this role,
  # under permissions:
  # 1. Navigate to IAM
  # 2. Create a User with Programmatic access
  # 3. Click Next: Permissions
  # 4. Click the Attach existing policies directly box and Create policy
  # 5. Use the visual editor to select the S3 Service. We only need a couple of access requirements; so expand out the access level groups
  # 6. Ensure that GetObject under the READ section and PutObject under the write section are both ticked.
  # 7. Set the resources you want to grant access to; specify the bucket name you created earlier and click Any for the object name.
  # 8. We’re not specifying any Request conditions
  # 9. Click Review Policy and enter a name for the policy. Save the policy

  def gen_rand_name(cfg \\ @aws_default_cfg)

  def gen_rand_name(cfg) when is_atom(cfg) do
    gen_rand_name(get_cfg(cfg))
  end

  def gen_rand_name(cfg) do
    name = Ecto.UUID.generate() |> String.replace("-", "")
    ## for shorter names..
    # |> String.slice(5..17)

    case S3.head_object(cfg.bucket, name) |> ExAws.request(cfg) do
      {:ok, _} ->
        gen_rand_name(cfg)

      {:error, _} ->
        name
    end
  end

  @doc ~S"""
  get a presigned url and file name
  preference is to call with name=nil, so it generates the name for us.  only
  include name when uploading a new picture on an existing item to replace the
  image.

  Where bucket is like :images, which is a key in the configs
  """
  def gen_download_url(name, role \\ @aws_default_cfg) do
    cfg = get_cfg(role)

    with {:error, reason} <- S3.presigned_url(cfg, :put, cfg.bucket, name) do
      Logger.error("failed to generate presigned URL in bucket #{cfg.bucket}", reason: reason)
      {:error, "unable to generate presigned download url"}
    end
  end

  @doc """
  remove object from S3, using a keyed config
  """
  def delete_object(object, role \\ @aws_default_cfg) do
    cfg = get_cfg(role)

    case S3.delete_object(cfg.bucket, object) |> ExAws.request(cfg) do
      {:ok, %{status_code: 204}} ->
        {:ok, :deleted}

      {:error, what} ->
        Logger.error("S3 unable to delete object", detail: what)
        {:error, what}

      other ->
        {:error, other}
    end
  end
end
