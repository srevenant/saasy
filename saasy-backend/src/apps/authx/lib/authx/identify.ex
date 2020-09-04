defmodule AuthX.Identify do
  @moduledoc """
  """
  require Logger

  use Core.ContextClient
  use AuthX.ContextTypes

  ###########################################################################
  @doc """
  This calls __MODULE__.check/2 on the appropriate sub module of Signin,
  as is configured in App.Settings (Default is AuthX.Signin.Local)
  """
  @spec identify(Tenant.t(), Map.t()) :: auth_result
  def identify(%Tenant{} = tenant, %{email: eaddr}) do
    case UserEmails.all!(tenant_id: tenant.id, address: eaddr) do
      [%UserEmail{} = email] ->
        {:exists, email}

      _other ->
        # create new user profile with identity info only
        Users.signup_only_identity(%AuthDomain{
          tenant: tenant,
          input: %{email: %{address: eaddr, verified: false}, settings: %{}}
        })
    end
  end

  def identify(_, _), do: :error
end
