defmodule Core.ContextClient do
  @moduledoc """
  Makes using Core contexts easy. Aliases the majority of things needed.
  """

  defmacro __using__(_) do
    quote do
      # I dislike the more lengthy String.t(), and 'string' is something else
      alias Ecto.Changeset

      alias Core.Model.{
        Tenant,
        Tenants,
        TenantDomain,
        TenantDomains
      }

      # identity things
      alias Core.Model.{
        User,
        Users,
        UserHandle,
        UserHandles,
        UserPhone,
        UserPhones,
        UserEmail,
        UserEmails,
        UserData,
        UserDatas
      }

      # auth things
      alias Core.Model.{
        Factor,
        Factors,
        Action,
        Actions,
        Access,
        Accesses,
        RoleMap,
        RoleMaps,
        Role,
        Roles
      }

      # subscription things
      alias Core.Model.{
        Summary,
        Summarys,
        SummaryUser,
        SummaryUsers,
        Setting,
        Settings,
        SettingScheme,
        SettingSchemes,
        Usage,
        Usages
      }

      alias Core.Model.{
        AuthDomain,
        AuthFedId,
        AuthFedIdEmail,
        AuthFedIdProvider
      }

      alias Core.Model.Upload

      require Logger
    end
  end
end
