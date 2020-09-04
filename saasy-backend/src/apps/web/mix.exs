defmodule Web.Mixfile do
  use Mix.Project

  def project do
    [
      app: :web,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Web.Application, []},
      extra_applications: [:logger, :ueberauth, :runtime_tools]
      # applications: [:logger, :ueberauth]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:core, in_umbrella: true},
      {:utils, in_umbrella: true},
      {:authx, in_umbrella: true},
      {:absinthe, "~> 1.4.13"},
      {:absinthe_plug, "~> 1.4.0"},
      {:cors_plug, "~> 1.5"},
      {:gettext, "~> 0.11"},
      {:mix_test_watch, ">= 0.0.0", only: [:test, :dev], runtime: false},
      {:phoenix, "~> 1.4.2"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:poison, "~> 3.0"},
      {:joken, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:ueberauth, "~> 0.5"},
      {:ueberauth_google, "~> 0.7"},
      {:deep_merge, "~> 1.0"},
      {:hammer, "~> 6.0"}
    ]
  end

  defp docs do
    [
      source_url_pattern:
        "https://github.com/srevenant/reactor-backend/blob/master/apps/reactor-backend/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end
end
