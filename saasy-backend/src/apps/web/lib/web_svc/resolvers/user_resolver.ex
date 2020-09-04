defmodule WebSvc.Resolvers.UsersResolver do
  @moduledoc """
  Resolver for interacting with `Core.Users`
  """
  import Web.Absinthe
  import Utils.Types, only: [strip_keys_not_in: 2, strip_subdict_values_not: 3]
  use Core.ContextClient
  require Logger

  @doc """
  If handle exists, put it in so the GraphQL query returns a string
  """
  def reduce_handle(_args, %{source: %User{} = user}) do
    case Users.preload(user, :handle, force: true) do
      {:ok, %User{handle: handle}} when not is_nil(handle) ->
        {:ok, handle.handle}

      {:ok, %User{} = _user} ->
        {:ok, ""}

      error ->
        error
    end
  end

  # if not authed
  def reduce_handle(_args, _info), do: {:ok, nil}

  def resolve_verified_email(_args, %{source: %User{} = user}) do
    case Users.preload(user, :emails) do
      {:ok, %User{emails: emails}} ->
        if is_list(emails) do
          if Enum.find(emails, fn e -> e.verified end),
            do: {:ok, true},
            else: {:ok, false}
        else
          {:ok, false}
        end

      _ ->
        {:ok, false}
    end
  end

  def resolve_verified_email(_args, _) do
    {:ok, false}
  end

  @doc """
  Resolve the current user from context
  """
  def query_self(_args, info) do
    with_current_user(
      info,
      "self",
      fn current_user ->
        {:ok, current_user}
      end,
      fn _ ->
        Logger.info("query self when not signed in")
        {:ok, %{authStatus: :unknown}}
      end
    )
  end

  @allowed_keys [
    "authAllowed",
    "theme"
  ]
  def clean_settings(settings) when is_nil(settings), do: clean_settings(%{})

  def clean_settings(settings) when is_map(settings) do
    strip_keys_not_in(settings, @allowed_keys)
    |> strip_subdict_values_not("authAllowed", &is_boolean/1)
  end

  ##############################################################################
  @doc """
  Administratively update the profile of a different user.
  """
  def mutate_update_user(args, info) do
    with_authz_action(info, :user_admin, "updatePerson", fn admin ->
      {id, args} = Map.pop(args, :id)

      case Users.one(id: id, tenant_id: admin.tenant_id) do
        {:ok, user} ->
          update_person(args, user)

        {:error, _} ->
          {:error, "No user found with this ID."}
      end
    end)
  end

  ##############################################################################
  # @doc """
  # Update the profile of the user.  Only accepts one change at a time.
  # """
  defp update_allowed(%User{id: a_id}, %User{id: u_id}) when u_id === a_id, do: :yes

  defp update_allowed(%User{} = actor, %User{}) do
    actor = Users.get_authz(actor)

    # check for admin
    if MapSet.member?(actor.authz, :user_admin) do
      :yes
    else
      {:ok, %{success: false, reason: "you are not authorized to make that change"}}
    end
  end

  def mutate_update_person(%{id: id} = args, info) do
    with_current_user(info, "updatePerson", fn actor ->
      with {:ok, user} <- Users.one(id: id),
           :yes <- update_allowed(actor, user) do
        update_person(args, user)
      end
    end)
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(%{name: name}, %User{} = user) do
    case Users.update(user, %{name: name}) do
      {:ok, user} -> {:ok, %{success: true, result: user}}
      _other -> {:ok, %{success: false}}
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(%{settings: settings}, %User{} = user) do
    case Users.update(user, %{settings: Poison.decode!(settings) |> clean_settings}) do
      {:ok, user} -> {:ok, %{success: true, result: user}}
      _other -> {:ok, %{success: false}}
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(%{handle: handle}, %User{} = user) do
    {:ok, user} = Users.preload(user, [:handle])

    if String.length(handle) == 0 do
      if !is_nil(user.handle) do
        UserHandles.delete(user.handle)
      end

      {:ok, %{success: true, result: Users.preload!(user, [:handle])}}
    else
      case UserHandles.available(handle) do
        {:ok, _available_msg} ->
          case UserHandles.create(%{handle: handle, user_id: user.id, tenant_id: user.tenant_id}) do
            {:ok, _new} ->
              # if handle?
              if !is_nil(user.handle) do
                UserHandles.delete(user.handle)
              end

              {:ok, %{success: true, result: Users.preload!(user, [:handle])}}

            {:error, %Ecto.Changeset{} = chgset} ->
              {:ok, %{success: false, reason: Utils.Errors.convert_error_changeset(chgset)}}
          end

        {:error, private, public} ->
          Logger.error(private)
          {:ok, %{success: false, reason: public}}
      end
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(%{phone: phone}, %User{} = user) do
    case Users.add_phone(user, phone) do
      {:ok, _email} ->
        {:ok, %{success: true, result: Users.preload!(user, :phones)}}

      {:error, reason} ->
        {:ok, %{success: false, reason: reason}}
    end
  end

  def update_person(%{rmphone: phone_id}, %User{} = user) do
    user_id = user.id

    case UserPhones.one(id: phone_id) do
      {:ok, %UserPhone{user_id: ^user_id} = phone} ->
        case UserPhones.delete(phone) do
          {:ok, _} ->
            {:ok, %{success: true, result: Users.preload!(user, :phones)}}

          _ ->
            {:ok, %{success: false, reason: "could not remove phone"}}
        end

      _ ->
        {:ok, %{success: false, reason: "could not find phone"}}
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(%{email: email}, %User{} = user) do
    case Users.add_email(user, email) do
      {:ok, _email} ->
        {:ok, %{success: true, result: Users.preload!(user, :emails)}}

      {:error, reason} ->
        {:ok, %{success: false, reason: reason}}
    end
  end

  def update_person(%{rmemail: email_id}, %User{} = user) do
    user_id = user.id

    case UserEmails.one(id: email_id) do
      {:ok, %UserEmail{user_id: ^user_id} = email} ->
        case UserEmails.delete(email) do
          {:ok, _} ->
            {:ok, %{success: true, result: Users.preload!(user, :emails)}}

          _ ->
            {:ok, %{success: false, reason: "could not remove email"}}
        end

      _ ->
        {:ok, %{success: false, reason: "could not find email"}}
    end
  end

  def update_person(%{verifyemail: email_id}, %User{} = user) do
    user_id = user.id

    case UserEmails.one(id: email_id) do
      {:ok, %UserEmail{user_id: ^user_id} = email} ->
        Users.send_verify_email(email)
        {:ok, %{success: true, result: user}}

      _ ->
        {:ok, %{success: false, reason: "could not find email"}}
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(%{user_data: %{value: _, type: type} = data}, %User{} = user) do
    with {:ok, value} <- Poison.decode(data.value) do
      case data do
        %{id: id} ->
          with {:ok, current} <- UserDatas.one(id: id) do
            UserDatas.update(current, %{value: value})
          end

        %{user_id: u_id} ->
          UserDatas.create(%{user_id: u_id, type: type, value: value})

        err ->
          IO.inspect(err, label: "Invalid user_data args")
          {:error, "invalid args for user_data"}
      end
      |> case do
        {:ok, %UserData{}} ->
          user = Users.preload!(user, :data, force: true)
          {:ok, %{success: true, result: user}}

        {:error, %Ecto.Changeset{}} = err ->
          err

        other ->
          IO.inspect(other, label: "updatePerson failed")
          {:ok, %{success: false, reason: "unable to update with user data"}}
      end
    else
      _err -> {:ok, %{success: false, reason: "unable to decode json"}}
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_person(args, _) do
    IO.inspect(args, label: "updatePerson bad args")
    graphql_error("updatePerson", "unsupported argument")
  end

  ##############################################################################
  def resolve_emails(_args, %{source: %User{} = user}) do
    {:ok, Users.preload!(user, :emails).emails}
  end

  # if not authed
  def resolve_emails(_args, _info), do: {:ok, nil}

  def resolve_phones(_args, %{source: %User{} = user}) do
    {:ok, Users.preload!(user, :phones).phones}
  end

  # if not authed
  def resolve_phones(_args, _info), do: {:ok, nil}

  ##############################################################################
  def resolve_factors(%{historical: true}, %{source: %User{} = user}) do
    {:ok, Users.preload!(user, :factors).factors}
  end

  def resolve_factors(%{type: type}, %{source: %User{id: user_id} = user})
      when not is_nil(user_id) do
    {:ok, Factors.all_not_expired!(user, type)}
  end

  def resolve_factors(_, %{source: %User{id: user_id} = user}) when not is_nil(user_id) do
    {:ok, Factors.all_not_expired!(user)}
  end

  def resolve_factors(_args, _info), do: {:ok, nil}

  ##############################################################################
  def resolve_access(_args, %{source: %User{} = user}) do
    user = Users.get_authz(user)

    {:ok,
     %{
       actions: MapSet.to_list(Users.get_authz(user).authz),
       roles:
         Enum.map(user.accesses, fn access ->
           Accesses.preload!(access, :role).role.name
         end)
     }}
  end

  def resolve_access(_args, _info), do: {:ok, %{roles: [], actions: []}}

  ##############################################################################
  defp ecto_query_to_result({:ok, results}, total),
    do: {:ok, %{success: true, results: results, total: total}}

  defp ecto_query_to_result({:error, chgset}, _total),
    do: {:ok, %{success: false, reason: Utils.Errors.convert_error_changeset(chgset)}}

  def resolve_settings(_, %{source: %User{} = user}) do
    {:ok, user.settings}
  end

  def resolve_settings(_, _), do: {:ok, %{}}

  # private
  def query_people(%{matching: matching}, info) when is_binary(matching) do
    if String.length(matching) == 0 do
      query_people(%{}, info)
    else
      with_authz_action(info, :auth_admin, "listPeople", fn admin ->
        matching =
          if is_binary(matching) do
            "%" <> matching <> "%"
          else
            "%"
          end

        Users.search(%{tenant_id: admin.tenant_id, matching: matching, limit: 25})
        |> ecto_query_to_result(Users.count!())
      end)
    end
  end

  def query_people(%{}, info) do
    with_authz_action(info, :auth_admin, "listPeople", fn admin ->
      Users.all([tenant_id: admin.tenant_id], %{limit: 25})
      |> ecto_query_to_result(Users.count!())
    end)
  end

  ##############################################################################
  # private
  def query_public_people(%{filter: %{name: name} = filter}, info) when is_binary(name) do
    with_current_user(info, "listPublicPeople", fn user ->
      matches =
        case UserHandles.one([handle: name], [:user]) do
          {:ok, handle} ->
            [handle.user]

          _ ->
            []
        end

      with {:ok, result} <-
             Core.Model.UserSearch.search(filter |> Map.merge(%{tenant_id: user.tenant_id}), user) do
        mapped = (matches ++ result) |> Enum.reduce(%{}, fn m, acc -> Map.put(acc, m.id, m) end)
        {:ok, Map.values(mapped)}
      end
      |> graphql_status_result
    end)
  end

  ##############################################################################
  def query_public_person(%{id: id}, info) do
    with_logging(info, "publicPerson-id", fn _ ->
      case Users.one(id: id) do
        {:ok, user} ->
          {:ok, %{success: true, result: user}}

        {:error, _} ->
          {:ok, %{success: false, reason: "cannot find user #{id}"}}
      end
    end)
  end

  def query_public_person(%{target: handle}, info) do
    with_logging(info, "publicPerson-handle", fn _ ->
      IO.inspect(handle)

      case UserHandles.one([handle: handle], [:user]) do
        {:ok, handle} ->
          {:ok, %{success: true, result: handle.user}}

        {:error, _} ->
          {:ok, %{success: false, reason: "cannot find user #{handle}"}}
      end
    end)
  end

  ##############################################################################
  def request_password_reset(%{email: eaddr}, info) when is_binary(eaddr) do
    user_id =
      if info.context.user do
        info.context.user.id
      else
        nil
      end

    eaddr = String.trim(eaddr)
    Logger.info("password reset request", user_id: user_id, eaddr: eaddr)

    case UserEmails.one([address: eaddr], [:user]) do
      {:ok, %UserEmail{} = email} ->
        case email.user do
          %User{type: :disabled} ->
            Logger.info("Ignoring attempt to reset disabled user", uid: email.user.id)

          _other ->
            AuthX.send_reset_code(email)
        end

      _ ->
        :ok
    end

    {:ok, %{success: true}}
  end

  ##############################################################################
  # need to throttle this ... (behind Hammer)
  def mutate_change_password(%{current: c, new: n, email: ""}, info),
    do: mutate_change_password(%{current: c, new: n}, info)

  def mutate_change_password(%{current: current, new: new, email: email}, info)
      when is_binary(email) do
    with_logging(info, "changePassword(reset)", fn _ ->
      case AuthX.change_password(email, current, new) do
        :ok -> {:ok, %{success: true}}
        :error -> {:ok, %{success: false, reason: "current password or reset code do not match"}}
      end
    end)
  end

  def mutate_change_password(%{current: current, new: new}, info) do
    with_current_user(info, "changePassword(change)", fn user ->
      # pass to authX module; accept reset code in lieu of password
      case AuthX.change_password(user, current, new) do
        :ok -> {:ok, %{success: true}}
        :error -> {:ok, %{success: false, reason: "current password or reset code do not match"}}
      end
    end)
  end

  ##############################################################################
  def resolve_auth_status(_, %Absinthe.Resolution{
        source: %User{id: user_id1},
        context: %{user: %User{id: user_id2} = user}
      })
      when user_id1 == user_id2 do
    # future: include user auth status where it can be identified or authenticated
    case user.type do
      :identity -> {:ok, :identified}
      :authed -> {:ok, :authed}
      _ -> {:ok, :unknown}
    end
  end

  def resolve_auth_status(_, _) do
    # case info do
    #   %Absinthe.Resolution{source: src} ->
    #     src
    #
    #   _ ->
    #     :ok
    # end

    {:ok, :unknown}
  end

  ##############################################################################
  def mutate_update_role(%{role: role, id: user_id}, info)
      when not is_nil(role) and not is_nil(user_id) do
    with_authz_action(info, :user_admin, "updateRole", fn admin ->
      case Users.one(id: user_id, tenant_id: admin.tenant_id) do
        {:ok, user} ->
          case Roles.one(id: role) do
            {:ok, role} ->
              case Accesses.one(user_id: user.id, role_id: role.id) do
                {:ok, _access} ->
                  nil

                {:error, _} ->
                  Accesses.delete_by_user(user.id)
                  Accesses.upsert(%{role_id: role.id, user_id: user.id})
              end

              {:ok, %{success: true, result: Users.preload!(user, [:accesses], force: true)}}

            {:error, _} ->
              graphql_error("updateRole", "Couldn't find role with given ID")
          end

        {:error, _} ->
          graphql_error("updateRole", "Couldn't find user with given ID.")
      end
    end)
  end

  ##############################################################################
  # todo: add in types filter
  @public_allowed %{profile: true, toggles: true}
  def resolve_public_user_data(src, args, info) do
    with {:ok, data} <- resolve_user_data(src, args, info) do
      {:ok,
       Enum.filter(data, fn elem ->
         ## TODO: use a switch to further filter things like address,
         ## after moving toggle for hiding or not onto address
         not is_nil(Map.get(@public_allowed, elem.type))
       end)}
    end
  end

  def resolve_user_data(%User{} = user, %{types: types}, _) do
    {:ok, UserDatas.list_types(user, types)}
  end

  def resolve_user_data(%User{} = user, _, _) do
    case Users.preload(user, :data) do
      {:ok, %User{data: nil}} -> {:ok, []}
      {:ok, %User{data: data}} -> {:ok, data}
    end
  end

  def resolve_user_data(_, _, _) do
    {:error, nil}
  end

  ##############################################################################
  def resolve_avatar(src, _, _) do
    case Upload.Files.all(ref_id: src.id, type: :avatar) do
      {:ok, [file | _]} ->
        {:ok, %{path: file.path}}

      _ ->
        {:ok, %{}}
    end
  end
end
