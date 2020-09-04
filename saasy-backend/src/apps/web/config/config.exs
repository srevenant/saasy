# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :web,
  namespace: Web

# Configures the endpoint
config :web, WebSvc.Endpoint,
  http: [port: 4000],
  url: [host: nil],
  secret_key_base: "KaoKbXwAxyUkkkLnmwaXI7dS//MnWEwA6HZuXqdhojsEphz6Qmj9BoKeITkfbkx7",
  render_errors: [view: WebSvc.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Web.PubSub, adapter: Phoenix.PubSub.PG2]

# On an invalid URL, redirect to marketing website
config :web, :redirect_target_url, "http://localhost"

# DEFAULT CORS origin
config :web, :cors_plug, origin: ["http://localhost:3000", "http://localhost:4000"]

# Rate limiting for authx security
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
