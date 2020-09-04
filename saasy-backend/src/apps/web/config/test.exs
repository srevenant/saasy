use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web, WebSvc.Endpoint,
  http: [port: 4010],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :ex_unit, capture_log: true
