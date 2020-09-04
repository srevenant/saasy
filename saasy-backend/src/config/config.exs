# MOST configuration should go into the umbrella core app at apps/core/config/

use Mix.Config

import_config "../apps/*/config/config.exs"

# changed at release time by docker/release/Dockerfile
config :web, release_version: "dev"

# Override for improved log output.
config :logger,
  backends: [:console],
  truncate: :infinity,
  # go look in Utils.ConsoleFormatLogger for @blacklisted_metadata_keys, in
  # order to filter individual metadata elements
  #  format: "$time [$level] $levelpad$message $metadata\n",
  compile_time_purge_matching: [
    [level_lower_than: :info]
    #    [application: :foo],
    #    [module: Bar, function: "foo/3", level_lower_than: :error]
  ]

# go look in Utils.ConsoleFormatLogger for @blacklisted_metadata_keys, in
# order to filter individual metadata elements
config :logger, :console,
  format: {Util.ConsoleFormatLogger, :format},
  # Look into Util.ConsoleFormatLogger for blacklisting
  metadata: :all

# if Mix.env() != :test do
#  # Logging that doesn't apply to tests
#  config :logger,
#    # these two (otp/sasl) provide a lot of contextual noise around processes at startup,
#    # but after startup are less noisy--but are both very valuable for debugging processes
#    handle_otp_reports: true,
#    handle_sasl_reports: true
# end

if Mix.env() != :prod do
  config :mix_test_watch,
    clear: true
end
