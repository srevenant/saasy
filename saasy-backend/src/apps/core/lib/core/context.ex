defmodule Core.Context do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @timestamps_opts [type: :utc_datetime]
      import Ecto, only: [assoc: 2]
      import Ecto.Changeset
      import Ecto.Query, except: [update: 2, update: 3]

      alias Ecto.Multi
      alias Ecto.Changeset

      alias Core.Repo
      # includes all the aliases for referencing contexts and their return
      # structs.
      use Core.ContextClient
    end
  end
end
