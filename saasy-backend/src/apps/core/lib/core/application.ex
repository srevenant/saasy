defmodule Core.Application do
  @moduledoc """
  An application that owns the core business entities and business logic.
  """

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    {:ok, _} = Core.HostCache.start()
    {:ok, _} = Core.RoleCache.start()
    Faker.start()

    children = [
      {Core.Repo, []}
      # {Util.Interval, [%{module: Core.Housekeeper, function: :groom, interval: 1000}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
