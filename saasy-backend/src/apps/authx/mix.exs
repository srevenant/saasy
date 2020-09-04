defmodule AuthX.MixProject do
  use Mix.Project

  def project do
    [
      app: :authx,
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
      extra_applications: [:logger, :timex, :httpoison],
      mod: {AuthX.Application, []}
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
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:utils, in_umbrella: true},
      {:core, in_umbrella: true},
      {:ex_machina, "~> 2.3.0", only: :test},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:timex, "~> 3.6"},
      # to refresh google certs
      {:httpoison, "~> 1.6"},
      # for JWTs -- look into rewriting w/Joken2.0 when time allows
      # TODO: https://hexdocs.pm/joken/migration_from_1.html
      {:joken, "~> 2.0"},
      # for local auth
      {:bcrypt_elixir, "~> 1.1.1"},
      # when time allows investigate ueberauth more fully.  when I last checked,
      # it was tightly coupled to the user record structure, and I'd like
      # it to be less tight so we can have some flexibility, so just use
      # bits of it for now -BJG 2019-Sep-12
      # (note: this also brings in oauth2)
      # for when time allows, spend a day: http://blog.nathansplace.co.uk/2018/ueberauth-and-guardian
      # -- will have to change frontend too
      {:ueberauth_google, "~> 0.8"}
    ]
  end

  defp docs do
    [
      source_url_pattern: "https://github.com/{baseurl}/blob/master/apps/auth/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end
end
