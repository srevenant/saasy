defmodule Utils.MixProject do
  use Mix.Project

  def project do
    [
      app: :utils,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.4", override: true},
      #      {:phoenix_html, ">= 0.0.0"},
      {:poison, ">= 0.0.0"},
      # for creating auth validation token secrets; RandChars
      {:entropy_string, "~> 1.3"},
      # for local auth
      {:bcrypt_elixir, "~> 1.1.1"},
      # time parsing
      {:timex, "~> 3.0"}
    ]
  end
end
