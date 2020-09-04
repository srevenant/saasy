defmodule Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :postgrex, :ecto, :timex],
      mod: {Core.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "core.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:utils, in_umbrella: true},
      {:ecto, "~> 3.4", override: true},
      {:ecto_enum, "~> 1.0"},
      {:ex_machina, "~> 2.3.0", only: :test},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:faker, "~> 0.10"},
      {:postgrex, "~> 0.13"},
      {:yaml_elixir, "~> 2.5.0"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 0.6", only: [:test, :dev], runtime: false},
      {:timex, "~> 3.6"},
      # for safe escaping values (email)
      {:phoenix_html, ">= 0.0.0"},
      {:dataloader, "~> 1.0.0"},
      {:csv, "~> 2.3"},
      {:lazy_cache, "~> 0.1.0"},
      # send email
      {:bamboo, "~> 1.4"},
      {:bamboo_smtp, "~> 2.1.0"},
      # strip_html for emails
      {:html_sanitize_ex, "~> 1.4"},
      # s3 integration
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      # used in mix task only, for now
      {:httpoison, "~> 1.7"}
    ]
  end

  defp docs do
    [
      source_url_pattern:
        "https://github.com/srevenant/saasy-backend/blob/master/apps/core/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end
end
