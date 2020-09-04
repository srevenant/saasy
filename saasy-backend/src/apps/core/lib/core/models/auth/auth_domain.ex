# original content from Protos LLC/Brandon Gillespie, License for use per addendum (exhibit A) to noncompete/nda
defmodule Core.Model.AuthDomain do
  @moduledoc """
  Structure for in-process authentication result contexts, not directly to one user
  """
  alias __MODULE__

  defstruct type: :acc,
            status: :unknown,
            authz: %{},
            user: nil,
            tenant: nil,
            user: nil,
            email: nil,
            handle: nil,
            token: nil,
            factor: nil,
            created: false,
            log: nil,
            error: nil,
            input: nil

  @type t :: %AuthDomain{
          type: atom,
          status: atom,
          authz: map,
          user: nil | User.t(),
          tenant: nil | Tenant.t(),
          user: nil | User.t(),
          handle: nil | UserHandle.t(),
          email: nil | UserEmail.t(),
          factor: nil | Factor.t(),
          token: nil | map,
          created: boolean,
          # log is what we save in the logs
          log: nil | String.t(),
          # error is what we send users (default: Signin Failed)
          error: nil | String.t(),
          input: nil | map
        }
end
