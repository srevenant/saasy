# original content from Protos LLC/Brandon Gillespie, License for use per addendum (exhibit A) to noncompete/nda
defmodule AuthX.Token.Request do
  @moduledoc """
  Structure for in-process authentication contexts, not directly to one user
  """
  alias __MODULE__

  defstruct sub: nil,
            tenant: nil,
            tenant_code: nil,
            type: nil,
            for: nil,
            exp: nil,
            secret: nil

  @type t :: %Request{
          sub: nil | String.t(),
          tenant: nil | AuthX.Model.Tenant.t(),
          tenant_code: nil | String.t(),
          type: atom,
          for: map,
          exp: nil | integer,
          secret: nil | binary
        }
end
