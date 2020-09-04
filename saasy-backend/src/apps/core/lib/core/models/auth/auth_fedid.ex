defmodule Core.Model.AuthFedIdEmail do
  defstruct address: "",
            verified: false

  @type t :: %__MODULE__{
          address: String.t(),
          verified: boolean
        }
end

defmodule Core.Model.AuthFedIdProvider do
  defstruct type: :unknown,
            kid: nil,
            jti: nil,
            iss: nil,
            iat: nil,
            exp: 0,
            azp: nil,
            aud: nil,
            token: nil

  @type t :: %__MODULE__{
          type: atom,
          kid: nil | String.t(),
          jti: nil | String.t(),
          iss: nil | String.t(),
          iat: nil | String.t(),
          exp: 0 | integer,
          azp: nil | String.t(),
          aud: nil | String.t(),
          token: nil | String.t()
        }
end

defmodule Core.Model.AuthFedId do
  @moduledoc """
  Structure for in-process authentication result contexts, not directly to one user
  """
  # alias __MODULE__

  # see enums for FactorNums -- this is any federated type
  defstruct name: nil,
            handle: nil,
            email: %Core.Model.AuthFedIdEmail{},
            phone: nil,
            settings: %{locale: "en"},
            provider: %Core.Model.AuthFedIdProvider{}

  @type t :: %__MODULE__{
          name: nil | String.t(),
          handle: nil | String.t(),
          email: Core.Model.AuthFedIdEmail.t(),
          phone: nil | String.t(),
          settings: map,
          provider: Core.Model.AuthFedIdProvider.t()
        }
end
