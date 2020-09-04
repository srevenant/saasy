defmodule WebSvc.UsersResolverTest do
  use WebSvc.ConnCase
  use Core.ContextClient
  import WebSvc.TestSupportAuth, only: [setup_graphql: 1]

  setup args, do: setup_graphql(args)

  describe "query myself" do
    test "get my data", %{conn: conn, user: user} do
      query = """
        query me {
          self {
            id
            name
          }
        }
      """

      conn = post(conn, "/graphql", %{query: query, variables: %{}})
      response = json_response(conn, 200)["data"]
      id = get_in(response, ["self", "id"])

      assert id == user.id
    end
  end
end
