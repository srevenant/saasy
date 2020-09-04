defmodule Mix.Tasks.Core.Seeds do
  use Mix.Task
  use Core.ContextClient
  use Core.TestDefinitions
  require Logger

  @moduledoc """
  Seed the database with the admin
  """
  @shortdoc "Seed the database with data to run or demo the platform."

  ##############################################################################
  def start_friends() do
    {:ok, _} = Application.ensure_all_started(:core)
    {:ok, _} = Application.ensure_all_started(:timex)
    Utils.Mix.ensure_started(Core.Repo, [])
    Faker.start()
  end

  ##############################################################################
  def run([]), do: run([Mix.env()])

  def run(args) do
    start_friends()

    Enum.each(args, fn arg ->
      seed(arg)
    end)
  end

  # break out for individual env settings as desired
  defp seed(env) when env in [:dev, :test, :prod] do
    seed(:all)
  end

  ##############################################################################
  defp seed(:all) do
    Logger.info("Basic seeding for all environments")

    create_list(Roles, [
      {[:name], %{name: :superadmin, description: "administrator"}},
      {[:name], %{name: :self, description: "self rights"}}
    ])

    superadmin = Roles.one!(name: :superadmin)

    Logger.info("Creating Auth roles")

    Enum.each(["auth", "user", "tenant", "setting", "subscription"], fn domain ->
      aname = Utils.Types.to_atom(domain)

      Enum.each(["admin", "view"], fn action ->
        name = Utils.Types.to_atom("#{domain}_#{action}")
        aaction = Utils.Types.to_atom(action)

        {:ok, action} =
          Actions.replace(
            %{
              name: name,
              domain: aname,
              action: aaction,
              description: "#{action} for #{domain}"
            },
            name: name
          )

        if aaction == :admin do
          RoleMaps.replace(
            %{
              role_id: superadmin.id,
              action_id: action.id
            },
            role_id: superadmin.id,
            action_id: action.id
          )
        end
      end)
    end)

    Logger.info("Creating GraphiQL dev role")

    {:ok, graphiql} =
      Actions.replace(
        %{
          name: :graphiql,
          domain: :dev,
          action: :graphiql,
          description: "graphiql dev"
        },
        name: :graphiql
      )

    RoleMaps.replace(
      %{
        role_id: superadmin.id,
        action_id: graphiql.id
      },
      role_id: superadmin.id,
      action_id: graphiql.id
    )
  end

  ##############################################################################
  # create a user, with specified username (if nill, it creates a random one)
  # format: tenant:email@domain
  defp seed("user=" <> target) do
    # {host, email, pass} =
    
      case String.split(target, ":") do
        [""] ->
          {"localhost", Utils.RandChars12.random() <> "@localhost", Utils.RandChars12.random()}

        [host, email, pass] ->
          {host, email, pass}
      end

    # borken
    # {:ok, _, user, _, _} = Tools.create_for_tenant(host, email, pass)
    # Logger.info("Seed host=#{host} email=#{email} password=#{pass} userId=#{user.id}")
  end

  defp seed("admin=" <> _target) do
    Logger.info("oops, haven't implemented this yet")
  end

  ##############################################################################
  defp seed("settings") do
    Logger.info("Seed Settings")

    create_list(SettingSchemes, [
      {[:name],
       %{scope: "test", name: "that-setting1", help: "no help1", scheme: %{type: "text"}}},
      {[:name],
       %{scope: "test", name: "this-setting2", help: "no help2", scheme: %{type: "text"}}},
      {[:name],
       %{scope: "test", name: "thar-setting3", help: "no help3", scheme: %{type: "text"}}},
      {[:name],
       %{scope: "test", name: "thot-setting?", help: "no help4", scheme: %{type: "boolean"}}}
    ])
  end

  defp seed(_) do
    IO.puts("""
    Syntax: mix core.seeds {seed}[ {seed}...]

      - with no seed it defaults to Mix.env() (dev/test/prod)

      dev, test, prod - do seeds for the environment
      user={tenant:email:password}
                   - create a user, if user is unspecified will generate one
      admin={userId}
                   - make userId(uuid) an admin
      settings     - add some settings for development
      journeys={Owner's userId}@{path-to-import-file}
                   - seed the Product Journey Map and Challenges.
      topic-schema={path-to-import-file}

    """)
  end

  ##############################################################################
  ## Utility functions
  defp replace(mod, {keys, map}) when is_map(map) do
    keywords =
      Enum.map(keys, fn k ->
        if k in keys do
          {k, Map.get(map, k)}
        end
      end)

    mod.replace(map, keywords)
  end

  # defp create_list(mod, %Tenant{} = tenant, [{keys, map} | items]) when is_map(map) do
  #   {:ok, _} = replace(mod, {keys, Map.put(map, :tenant_id, tenant.id)})
  #   create_list(mod, tenant, items)
  # end

  #  defp create_list(_mod, %Tenant{}, []), do: nil

  defp create_list(mod, [item | items]) when is_tuple(item) do
    {:ok, _} = replace(mod, item)
    create_list(mod, items)
  end

  defp create_list(_mod, []), do: nil

  # defp create_for_tenant(hostname, eaddr, pass) do
  #   {:ok, tenant} = Tenants.replace(%{code: hostname}, code: hostname)
  #
  #   TenantDomains.replace(%{name: hostname, tenant_id: tenant.id},
  #     name: hostname,
  #     tenant_id: tenant.id
  #   )
  #
  #   {:ok, %UserEmail{} = email} =
  #     case UserEmails.all(address: eaddr) do
  #       {:ok, []} ->
  #         {:ok, user} = Users.create(%{tenant_id: tenant.id})
  #
  #         {:ok, email} =
  #           UserEmails.create(%{tenant_id: tenant.id, user_id: user.id, address: eaddr})
  #
  #         UserEmails.preload(email, :user)
  #
  #       {:ok, list} ->
  #         if length(list) > 1 do
  #           raise "Too many email matches to continue"
  #         end
  #
  #         UserEmails.preload(Enum.at(list, 0), :user)
  #     end
  #
  #   user = email.user
  #   user_id = user.id
  #
  #   {:ok, %UserHandle{} = _handle} =
  #     case UserHandles.one(tenant_id: tenant.id, handle: eaddr) do
  #       {:ok, %UserHandle{user_id: ^user_id} = handle} ->
  #         {:ok, handle}
  #
  #       {:ok, _} ->
  #         raise "The handle is already taken by another user?"
  #
  #       {:error, _} ->
  #         UserHandles.create(%{user_id: user.id, tenant_id: tenant.id, handle: eaddr})
  #     end
  #
  #   # # multiples
  #   {:ok, factor} =
  #     Factors.create(%{
  #       user_id: user.id,
  #       type: :password,
  #       password: pass,
  #       expires_at: Utils.Time.epoch_time(:second) + 86400 * 30
  #     })
  #
  #   {:ok, tenant, user, email, factor}
  #
  #   #    create_list(Settings, tenant, [
  #   #      {[:tenant_id, :name], %{scope: "test", name: "that-setting1", value: "beep"}},
  #   #      {[:tenant_id, :name], %{scope: "test", name: "this-setting2", value: "boop"}},
  #   #      {[:tenant_id, :name], %{scope: "test", name: "thar-setting3", value: "bop"}},
  #   #      {[:tenant_id, :name], %{scope: "test", name: "thot-setting?", value: "true"}}
  #   #    ])
  # end
end
