defmodule WebSvc.GraphqlController do
  @moduledoc """
  Controller that exposes the GraphQL schema as a read-only schema.json response.
  Returns a schema.json file contents for an Absinthe schema.
  """
  use WebSvc, :controller
  require Logger

  @introspection_graphql Path.join([:code.priv_dir(:absinthe), "graphql", "introspection.graphql"])

  @doc """
  This does the same thing the Absinthe mix task does to generate the schema.

  https://github.com/absinthe-graphql/absinthe/blob/v1.2.0/lib/mix/tasks/absinthe.schema.json.ex
  """
  def download_schema(conn, _params) do
    Logger.info("Attempting to download GraphQL schema")

    with {:ok, query} <- File.read(@introspection_graphql),
         {:ok, result} <- Absinthe.run(query, WebSvc.Schema),
         {:ok, schema} <- Poison.encode(result, pretty: true) do
      send_resp(conn, 200, schema)
    else
      error ->
        message = "Error generating schema"
        Logger.error(message <> ": #{inspect(error)}")
        send_resp(conn, 500, message)
    end
  end
end
