defmodule WebSvc.Router do
  use WebSvc, :router

  pipeline :base_web do
    plug(CORSPlug, Application.get_env(:web, :cors_plug))
    plug(Plug.RequestId)
    plug(:fetch_session)
    plug(WebSvc.AuthLookup)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    #    plug(:protect_from_forgery) # TODO: put this back in; but was causing problems w/signin
    plug(:put_secure_browser_headers)
  end

  # a shim until I get more time to make this work properly
  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/authx" do
    pipe_through([:base_web, :browser])

    post("/v1/api/signon", WebSvc.AuthXController, :signon)
    post("/v1/api/refresh", WebSvc.AuthXController, :refresh)
    get("/v1/api/signout", WebSvc.AuthXController, :signout)
    post("/v1/api/signout", WebSvc.AuthXController, :signout)
    get("/v1/api/access", WebSvc.AuthXController, :access)
    # post("/v1/api/identify", WebSvc.AuthXController, :access)

    # TODO: look into other plugins  https://www.leighhalliday.com/cors-in-phoenix
    options("/v1/api/access", WebSvc.AuthXController, :options)
    options("/v1/api/signout", WebSvc.AuthXController, :options)
    options("/v1/api/signon", WebSvc.AuthXController, :options)
    options("/v1/api/refresh", WebSvc.AuthXController, :options)
    # options("/v1/api/identify", WebSvc.AuthXController, :options)
  end

  scope "/graphql" do
    pipe_through([:base_web, :api])

    if Mix.env() == :dev do
      forward(
        "/interactive",
        Absinthe.Plug.GraphiQL,
        schema: WebSvc.Schema,
        interface: :advanced,
        context: %{pubsub: WebSvc.Endpoint}
      )
    end

    # each individual resolver can decide if it should allow access or not
    forward("/", Absinthe.Plug, schema: WebSvc.Schema)

    get("/schema", WebSvc.GraphqlController, :download_schema)
  end

  scope "/" do
    # Use the default browser stack
    pipe_through(:base_web)
    pipe_through(:browser)
    get("/ev", WebSvc.VerifyEmailController, :verify)
    get("/", WebSvc.PageController, :index)
  end
end
