defmodule Mix.Tasks.Core.Tenant do
  use Mix.Task
  use Core.ContextClient
  import Utils.Types, only: [to_atom: 1]

  @shortdoc "create a new tenant"

  def start_friends() do
    {:ok, _} = Application.ensure_all_started(:core)
    {:ok, _} = Application.ensure_all_started(:timex)
    Utils.Mix.ensure_started(Core.Repo, [])
  end

  def syntax(error) do
    start_friends()

    # future: mix core.tenant admin {user-uuid}
    IO.puts("""
    Syntax:
      mix core.tenant add {domain}
      mix core.tenant add {domain} {admin@email}
      mix core.tenant rm {domain}

      mix core.tenant role-list
      mix core.tenant role-new {name} {description}
      mix core.tenant role-action-new {action} {name} {domain} {description}
      mix core.tenant role-add-action {name} {action}
      mix core.tenant role-useradd {rolename} {userid}
      mix core.tenant role-userdel {rolename} {userid}

      mix core.tenant user-list
      mix core.tenant user-list {name filter}
      mix core.tenant user-list-byemail {users-email}

      mix core.tenant user-type {userid} {type}
    """)

    if error do
      IO.puts("\n>> #{error}")
    end
  end

  def run(args) do
    start_friends()
    cmd(args)
  end

  def format_user(%User{} = user) do
    with {:ok, user} = Users.preload(user, [:emails, :handle]) do
      eaddr =
        case user do
          %{emails: [%UserEmail{address: eaddr} | _]} -> eaddr
          _ -> ""
        end

      handle =
        case user do
          %{handle: %UserHandle{handle: handle}} when is_binary(handle) ->
            handle

          _ ->
            ""
        end

      "#{user.id} #{user.type} #{handle} #{eaddr} #{user.name}"
    end
  end

  def cmd(["role-action-new", action, name, domain, desc]) do
    case Actions.create(%{
           name: to_atom(name),
           action: to_atom(action),
           domain: to_atom(domain),
           description: desc
         }) do
      {:ok, action} -> IO.puts("  Created Action: #{action.domain} - #{action.description}")
      {:error, nope} -> IO.inspect(nope)
    end
  end

  def cmd(["role-add-action", rolename, actionname]) do
    case Roles.one(name: to_atom(rolename)) do
      {:ok, role} ->
        case Actions.one(name: to_atom(actionname)) do
          {:ok, action} ->
            case RoleMaps.create(%{role_id: role.id, action_id: action.id}) do
              {:ok, _} -> IO.puts("Role #{role.name} has received #{action.name}")
              {:error, nope} -> IO.inspect(nope)
            end

          {:error, _} ->
            IO.puts("Cannot find action #{actionname}")
        end

      {:error, _} ->
        IO.puts("Cannot find role #{rolename}")
    end
  end

  def cmd(["role-new", name, desc]) do
    case Roles.create(%{name: to_atom(name), description: desc}) do
      {:ok, role} -> IO.puts("  Created Role: #{role.name} - #{role.description}")
      {:error, nope} -> IO.inspect(nope)
    end
  end

  def cmd(["role-useradd", rolename, userid]) do
    case Users.one(userid) do
      {:ok, user} ->
        case Roles.one(name: to_atom(rolename)) do
          {:ok, role} ->
            case Accesses.create(%{role_id: role.id, user_id: user.id}) do
              {:ok, _} -> IO.puts("User #{userid} added to role #{role.name}")
              {:error, what} -> IO.inspect(what, label: "Cannot add!")
            end

          {:error, _} ->
            IO.puts("Cannot find role #{rolename}")
        end

      {:error, _} ->
        IO.puts("Cannot find user #{userid}")
    end
  end

  def cmd(["add", domain, admin]) do
    {:ok, tenant} = Tenants.create_tenant(domain)
    Logger.info("Created tenant #{domain}")

    {:ok, user} =
      Users.create(%{tenant_id: tenant.id, settings: %{"authAllowed" => %{"google" => true}}})

    {:ok, _email} =
      UserEmails.create(%{user_id: user.id, address: admin, primary: true, tenant_id: tenant.id})

    {:ok, _handle} =
      UserHandles.create(%{
        tenant_id: tenant.id,
        user_id: user.id,
        handle: UserHandles.gen_good_handle(admin)
      })

    {:ok, superadmin} = Roles.one(name: :superadmin)
    Accesses.create(%{role_id: superadmin.id, user_id: user.id})
    Logger.info("Admin User email=#{admin} userId=#{user.id}")
  end

  def cmd(["rm", domain]) do
    {:ok, tenant} = Tenants.one(domain)
    {:ok, tenant} = Tenants.delete(tenant)
    IO.puts("#{inspect(tenant)}")
  end

  def cmd(["add", domain]) do
    {:ok, _tenant} = Tenants.create_tenant(domain)
    Logger.info("Created tenant #{domain}")
  end

  def cmd(["user-list"]) do
    Enum.each(Tenants.all!() |> Tenants.preload!([:domains]), fn x ->
      IO.puts("#{x.id} #{x.code}\n==> Domains:")
      IO.puts("==> Users:")

      Enum.each(Users.all!(tenant_id: x.id), fn user ->
        format_user(user)
        |> IO.puts()
      end)
    end)
  end

  def cmd(["user-list", filter]) do
    Enum.each(Tenants.all!() |> Tenants.preload!([:domains]), fn x ->
      IO.puts("#{x.id} #{x.code}\n==> Domains:")
      IO.puts("==> Users:")
      rex = ~r/#{filter}/i

      Enum.each(Users.all!(tenant_id: x.id), fn user ->
        output = format_user(user)

        if Regex.match?(rex, output) do
          IO.puts(output)

          with {:ok, user} <- Users.preload(user, :accesses) do
            Enum.each(user.accesses, fn a ->
              with {:ok, a} = Accesses.preload(a, :role) do
                IO.puts("  -- #{a.role.name}")
                IO.puts("       #{RoleMaps.get_actions(a.role_id) |> Enum.join(" ")}\n")
              end
            end)

            IO.puts("  -- #{inspect(user.settings)}\n")
          end
        end
      end)
    end)
  end

  def cmd(["user-list-byemail", addr]) do
    Enum.each(Tenants.all!() |> Tenants.preload!([:domains]), fn x ->
      IO.puts("#{x.id} #{x.code}\n==> Domains:")
      IO.puts("==> Users:")

      Enum.each(UserEmails.all!(tenant_id: x.id, address: addr), fn email ->
        {:ok, email} = UserEmails.preload(email, [:user])

        format_user(email.user)
        |> IO.puts()
      end)
    end)
  end

  def cmd(["role-list"]) do
    Roles.all!()
    |> Enum.each(fn role ->
      IO.puts("- #{role.name} - #{role.description}")
      IO.puts("  {name} - {action} {domain} - {description}")

      RoleMaps.get_actions(role.id)
      |> Enum.each(fn aname ->
        {:ok, action} = Actions.one(name: aname)
        IO.puts("  #{action.name} - #{action.action} #{action.domain} - #{action.description}")
      end)
    end)
  end

  def cmd(["list"]) do
    Enum.each(Tenants.all!() |> Tenants.preload!([:domains]), fn x ->
      IO.puts("#{x.id} #{x.code}\n==> Domains:")

      Enum.each(x.domains, fn x ->
        IO.puts("  #{x.name}")
      end)
    end)
  end

  def cmd(args), do: syntax("Invalid Arguments: #{Enum.join(args, " ")}")
end
