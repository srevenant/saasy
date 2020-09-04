use Mix.Config

config :core, Core.Repo,
  username: "postgres",
  password: "",
  database: "reactor_#{Mix.env()}",
  hostname: "db",
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn

config :ex_unit, capture_log: true
