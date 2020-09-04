# original content from Protos LLC/Brandon Gillespie, License for use per addendum (exhibit A) to noncompete/nda
defmodule AuthX.Signin do
  @moduledoc """
  Tooling for the first phase of auth: decoupled signin with our customers.
  From here we go into Refresh.

  Support variable schemes under signin/ folder, for each tenant.

  TODO: Extract from Phoenix/WebSvc better, abstract so conn isn't needed
        This will require a module that is imported into WebSvc -BJG
  """
  #  alias Plug.Conn
  require Logger
  use Core.ContextClient
  import Users, only: [check_user_status: 1]
  use AuthX.ContextTypes

  ###########################################################################
  @doc """
  This calls __MODULE__.check/2 on the appropriate sub module of Signin,
  as is configured in App.Settings (Default is AuthX.Signin.Local)
  """
  @spec create(Atom.t(), Tenant.t(), Map.t()) :: auth_result
  def create(_type, %Tenant{} = tenant, params) do
    AuthX.Signin.Local.create(tenant, params)
  end

  ###########################################################################
  @spec check(Atom.t(), Tenant.t(), Map.t()) :: auth_result
  def check(:local, arg1, params) do
    # arg1 can be conn or authdomain
    AuthX.Signin.Local.check(arg1, params)
  end

  ###########################################################################
  # the rest are common utility methods for other modules to call (DRY)
  @doc """
  Find a user by their email address and normalize the output to our %AuthDomain
  """
  @spec find_by_email_and_link(Tenant.t(), AuthFedId.t(), atom) :: auth_result
  def find_by_email_and_link(
        %Tenant{} = tenant,
        %AuthFedId{email: %AuthFedIdEmail{verified: true, address: eaddr}} = fedid,
        _idp_token
      ) do
    case UserEmails.all!(tenant_id: tenant.id, address: eaddr)
         |> Enum.map(fn e ->
           UserEmails.preload!(e, [:user])
         end) do
      [%UserEmail{user: user} = email] ->
        with {:ok, user} <- check_user_status(user) do
          case user.settings do
            %{"authAllowed" => %{"google" => true}} ->
              {:ok, factor} = Factors.set_factor(email.user, fedid)

              {:ok,
               %AuthDomain{
                 tenant: tenant,
                 email: email,
                 user: email.user,
                 factor: factor,
                 status: :authed
               }}

            _ ->
              {:error,
               %AuthDomain{
                 log: "Federated signin when user already exists",
                 error:
                   "The address #{eaddr} is already known, and does not support #{
                     fedid.provider.type
                   } logins. You can try to reset your password."
               }}
          end
        else
          _error -> {:error, %AuthDomain{error: "user is not signed in"}}
        end

      _other ->
        # create new user profile with federated info
        Users.signup(%AuthDomain{
          tenant: tenant,
          status: :authed,
          input: %{
            fedid: fedid,
            name: fedid.name,
            handle: fedid.handle,
            # todo: we should retain the 'verified' on this email
            email: fedid.email,
            settings: %{authAllowed: Map.put(fedid.settings, fedid.provider.type, true)}
          }
        })
    end
  end
end
