use Mix.Config

config :core, Core.Repo,
  pool_size: 5,
  username: "postgres",
  password: "",
  database: "reactor_#{Mix.env()}",
  hostname: "db",
  log: false
