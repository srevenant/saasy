defmodule WebSvc.Schema do
  @moduledoc """
  The GraphQL schema definition for Web.
  """
  use Absinthe.Schema

  # alias WebSvc.Resolvers.{
  #   UsersResolver,
  #   SettingsResolver,
  #   GameResolver,
  #   JourneyResolver,
  #   JourneyResolver,
  #   ActivityResolver
  # }

  import_types(Absinthe.Type.Custom)
  import_types(WebSvc.Schema.Custom.JSON)
  import_types(WebSvc.Schema.Custom.Types)

  import_types(WebSvc.Schema.SaasySchema)
  import_types(WebSvc.Schema.UserSchema)
  import_types(WebSvc.Schema.UploadFileSchema)

  @doc """
  A callback specified by the `Absinthe.Schema` behaviour that gives the schema
  itself an opportunity to set some values in the context that it may need in
  order to run.
  """
  def context(ctx) do
    loader = Dataloader.new()

    Map.put(ctx, :loader, loader)
  end

  # defp data(ctx, query_fun) do
  #   # NOTE: Uses settings from
  #   # https://hexdocs.pm/dataloader/1.0.4/Dataloader.Ecto.html#module-filtering-ordering
  #   # Provides a `query` function that is used for filtering and ordering.
  #   # However, it can be used for more as well.
  #   Dataloader.Ecto.new(Core.Repo, [default_params: %{current_user: ctx.user}, query: query_fun])
  # end

  @doc """
  A callback specified by the `Absinthe.Schema` behaviour that specifies what
  plugins the schema needs to resolve.
  """
  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  ##############################################################################
  ##############################################################################
  query do
    import_fields(:saasy_queries)
    import_fields(:user_queries)
    import_fields(:upload_queries)
  end

  mutation do
    import_fields(:saasy_mutations)
    import_fields(:user_mutations)
    import_fields(:upload_mutations)
  end
end
