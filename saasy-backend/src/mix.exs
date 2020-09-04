defmodule Src.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # aliases
  defp aliases do
    [
      "format-check": ["format --check-formatted"],
      "check-format": ["format --check-formatted"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "core.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      diagram: ["run script/diagram.exs"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "ecto.seeds": ["core.seeds", "core.seed_contacts", "core.seed_contact_categories"]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      # {:exrm, "~> 1.0"},
      {:distillery, "~> 2.0"},
      {:tzdata, "~> 1.0"},
      {:timex, "~> 3.6"},
      {:mix_test_watch, "~> 0.8", only: [:test, :dev], runtime: false}
      #      {:observer_cli, "~> 1.3"} # debugging
    ]
  end
end
