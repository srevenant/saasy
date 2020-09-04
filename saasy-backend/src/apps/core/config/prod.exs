use Mix.Config

## NOTE: WE DO NOT USE COMPILE TIME CONFIGS FOR PROD, THIS IS JUST FOR DEFAULTS

config :core, Core.Repo,
  username: "postgres",
  password: "",
  database: "saasy_prd",
  hostname: "db",
  log: false

config :core, Core.Email.BambooMailer,
  adapter: Bamboo.SMTPAdapter,
  server: "mail.cold.org",
  hostname: "saasy.com",
  port: 25,
  # username: "your.name@your.domain", # or {:system, "SMTP_USERNAME"}
  # password: "pa55word", # or {:system, "SMTP_PASSWORD"}
  # can be `:always` or `:never`
  tls: :if_available,
  # allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  # ssl: false, # can be `true`
  retries: 2,
  # false, # can be `true`
  no_mx_lookups: true,
  # can be `:always`. If your smtp relay requires authentication set it to `:always`.
  auth: :if_available
