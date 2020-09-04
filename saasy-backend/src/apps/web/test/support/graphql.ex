defmodule WebSvc.TestSupportGraphQL do
  # import Core.Test.Factory
  # use Core.ContextClient
  # alias Plug.Conn

  # using to bring in post/json_response from outer module
  defmacro __using__(_) do
    quote do
      # defp after_query(%{"errors" => _} = errs) do
      #   IO.inspect(errs, label: "GraphQL Errors")
      #   nil
      # end
      #
      # defp after_query(%{"data" => data}) do
      #   data
      # end

      def graphql(%{conn: conn}, query, data),
        do: graphql(conn, %{query: query, variables: data})

      def graphql(conn, query, data),
        do: graphql(conn, %{query: query, variables: data})

      def graphql(%{conn: conn}, data),
        do: graphql(conn, data)

      def graphql(conn, data) do
        conn
        |> post("/graphql", data)
        |> json_response(200)
      end
    end
  end
end
