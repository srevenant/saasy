# original content from Protos LLC/Brandon Gillespie, License for use per addendum (exhibit A) to noncompete/nda
defmodule AuthX.Application do
  @moduledoc """
  An application that owns the auth business entities and business logic.
  """

  use Application

  def start(_type, _args) do
    # Configure ourself for runtime
    AuthX.Settings.start()

    # List all child processes to be supervised
    children = [
      {AuthX.GoogleKeyManager, %{interval: 4_000}}
    ]

    opts = [strategy: :one_for_one, name: AuthX.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
