defmodule Core.Test.SaasyFactory do
  use ExMachina.Ecto, repo: Core.Repo
  use Core.ContextClient

  defmacro __using__(_) do
    quote do
      ################################################################################
      def tenant_domain_factory do
        name = sequence("tenant")
        tenant = build(:tenant, code: name)

        %TenantDomain{
          name: name,
          tenant_id: tenant.id,
          tenant: tenant
        }
      end

      ################################################################################
      def action_factory do
        domain = sequence("action")

        %Action{
          domain: Utils.Types.to_atom(domain),
          action: Utils.Types.to_atom("edit"),
          name: Utils.Types.to_atom("#{domain}_edit"),
          description: "#{sequence("action")}_edit #{Faker.Cat.name()}"
        }
      end

      ################################################################################
      def role_factory do
        %Role{
          name: Utils.Types.to_atom("#{sequence("role")}"),
          description: "#{sequence("role")} #{Faker.Cat.name()}"
        }
      end

      ################################################################################
      def access_factory do
        user = insert(:user)
        role = insert(:role)

        %Access{
          user_id: user.id,
          role_id: role.id
        }
      end

      ################################################################################
      def role_map_factory do
        action = insert(:action)
        role = insert(:role)

        %RoleMap{
          action_id: action.id,
          role_id: role.id
        }
      end

      ################################################################################
      def tenant_factory do
        %Tenant{
          code: sequence("tenant")
        }
      end

      ################################################################################
      def user_factory do
        domain = insert(:tenant_domain)

        %User{
          tenant_id: domain.tenant.id,
          tenant: domain.tenant,
          name: "#{Faker.Person.first_name()} #{Faker.Person.last_name()}",
          settings: %{cat: Faker.Cat.name()}
        }
      end

      def handle_factory do
        user = build(:user)
        seq_id = sequence(:handle, &"#{&1}")

        %UserHandle{
          user: user,
          user_id: user.id,
          tenant_id: user.tenant.id,
          handle: "user-#{seq_id}"
        }
      end

      def phone_factory do
        user = build(:user)

        %UserPhone{
          user: user,
          user_id: user.id,
          number: Faker.Phone.EnUs.phone(),
          primary: false,
          verified: false
        }
      end

      def email_factory do
        user = build(:user)

        %UserEmail{
          user: user,
          user_id: user.id,
          tenant_id: user.tenant.id,
          address: Faker.Internet.email(),
          primary: false,
          verified: false
        }
      end

      ################################################################################
      def factor_factory do
        %Factor{
          user: build(:user),
          type: :unknown,
          expires_at: Utils.Time.epoch_time(:second) + 900
        }
      end

      ################################################################################
      # separate factory because hashing is expensive, and we only need this for a few
      # tests.  With it on everything it is slow. -BJG
      #
      # TODO: it shouldn't be necessary to hash it here, but the factory is bypassing
      # the Ecto module
      def hashpass_factor_factory do
        pass = Utils.RandChars12.random()

        %Factor{
          user: build(:user),
          type: :password,
          password: pass,
          hash: Utils.Hash.password(pass),
          expires_at: Utils.Time.epoch_time(:second) + 900
        }
      end

      # ################################################################################
      # def setting_group_factory do
      #   tenant = insert(:tenant)
      #
      #   %SettingGroup{
      #     tenant_id: tenant.id,
      #     name: sequence("setting.group"),
      #     help: "this is the parent for a group of settings"
      #   }
      # end
      #
      # def setting_global_factory do
      #   group = insert(:setting_group)
      #
      #   %SettingGlobal{
      #     group_id: group.id,
      #     name: sequence("setting.global"),
      #     help: "this is a global setting",
      #     value: %{}
      #   }
      # end

      def user_data_factory do
        user = insert(:user)

        %UserData{
          user_id: user.id,
          user: user,
          type: :available,
          value: %{}
        }
      end

      ################################################################################
      def usage_factory do
        tenant = insert(:tenant)

        %Usage{
          tenant_id: tenant.id,
          source: sequence("source"),
          start: Timex.now() |> Timex.to_unix()
        }
      end

      ################################################################################
      # def setting_factory do
      #   # This is a dependency, but not as a relationship in the db
      #   # insert is bad... ces la vie
      #   scheme = insert(:setting_scheme)
      #   tenant = insert(:tenant)
      #
      #   %Setting{
      #     tenant_id: tenant.id,
      #     scope: scheme.scope,
      #     name: scheme.name,
      #     value: "none"
      #   }
      # end
      #
      # ################################################################################
      # def setting_scheme_factory do
      #   %SettingScheme{
      #     scope: "ui",
      #     name: sequence("setting"),
      #     scheme: %{},
      #     help: "none"
      #   }
      # end
    end
  end
end
