# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :core, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:core, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

## Logger
config :logger, level: :info

config :core,
  ecto_repos: [Core.Repo],
  create_tenant_on_auth: true

# config :core, Core.Mailer,
#     adapter: Bamboo.TestAdapter

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

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

config :core, :email,
  link_front: "http://localhost:3000",
  link_back: "http://localhost:4000",
  unsubscribe: "http://localhost:3000/unsub",
  org: "s-reactor",
  email_from: "noreply@saasy.com",
  support: "support@saasy.com",
  email_sig: "The s-reactor team!"

config :core, :aws_s3,
  uploads: [
    bucket: "i.saasy.com",
    access_key_id: System.get_env("AWS_S3_BUCKET_KEY"),
    secret_access_key: System.get_env("AWS_S3_BUCKET_SECRET"),
    region: "us-west-2",
    prefix: ""
  ]

import_config "#{Mix.env()}.exs"
