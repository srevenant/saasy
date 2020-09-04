defmodule WebSvc.Resolvers.SaasyResolver do
  @moduledoc """
  Resolver for interacting with Saasy items
  """
  import Web.Absinthe
  use Core.ContextClient
  require Logger

  @doc """
  Resolve the current user from context
  """
  # def list_globals(_args, %{source: %SettingGroup{id: group_id}}) do
  #   SettingGlobals.all(group_id: group_id)
  # end
  #
  # def settings(%{name: name}, %Absinthe.Resolution{context: %{tenant: tenant}})
  #     when not is_nil(tenant) do
  #   SettingGroups.one(tenant_id: tenant.id, name: name)
  # end

  def resolve_actions(_args, %{source: %Role{} = role}) do
    {:ok, RoleMaps.get_actions(role.id)}
  end

  defp ecto_query_to_result({:ok, results}, total),
    do: {:ok, %{success: true, results: results, total: total}}

  defp ecto_query_to_result({:error, chgset}, _total),
    do: {:ok, %{success: false, reason: Utils.Errors.convert_error_changeset(chgset)}}

  def query_roles(%{name: name}, info) do
    with_authz_action(info, :user_admin, "listRoles", fn _admin ->
      Roles.one(name: name)
      |> ecto_query_to_result(Roles.count!())
    end)
  end

  def query_roles(_args, info) do
    with_authz_action(info, :user_admin, "listRoles", fn _admin ->
      Roles.all()
      |> ecto_query_to_result(Roles.count!())
    end)
  end

  def generate_new_validation(user) do
    {:ok, _token, _secret, validation} =
      AuthX.Token.Requests.validation_token(user, %{"t" => "refresh"}, :user)

    {:ok, validation} = Factors.update(validation, %{name: "generated apikey"})
    validation
  end

  # def mutate_gen_apikey(%{}, info) do
  #   with_subscription(info, "genApikey", &user_is_subscribed/1, fn user, _forward ->
  #     validation =
  #       case Factors.all(user_id: user.id, type: :valtok, name: "generated apikey") do
  #         {:ok, [validation | _]} ->
  #           validation
  #
  #         {:ok, []} ->
  #           generate_new_validation(user)
  #
  #         {:error, _} ->
  #           generate_new_validation(user)
  #       end
  #
  #     token = AuthX.Token.Requests.access_token(%Factor{validation | user: user})
  #
  #     valtok = AuthX.Token.Requests.gen_valtok_from_factor!(validation, %{"t" => "refresh"}, user)
  #
  #     {:ok,
  #      %{
  #        access: token,
  #        validation: %{
  #          sub: "cas2:" <> valtok,
  #          aud: "caa1:ref:#{user.tenant.code}",
  #          sec: validation.value
  #        }
  #      }}
  #   end)
  # end

  # # duplicated @subscribe_role is bad
  # @subscription_role :subscription_trader
  # def mutate_get_invites(%{}, info) do
  #   with_subscription(info, "genInvites", &user_is_subscribed/1, fn user, _ ->
  #     case InvitationCodes.unused(user.id) do
  #       {:ok, codes} ->
  #         codes =
  #           if length(codes) <= 5 do
  #             {:ok, code} = InvitationCodes.generate_invite(user.id, @subscription_role)
  #             codes ++ [code]
  #           else
  #             codes
  #           end
  #
  #         {:ok, %{codes: Enum.map(codes, fn code -> code.code end)}}
  #
  #       err ->
  #         IO.inspect(err, label: "getInvites error")
  #         graphql_error("getInvites", "unexpectedly cannot query codes")
  #     end
  #   end)
  # end

  ##############################################################################
  # with valid it's just marking done or not
  ####
  #### TODO: wrap user_id into object and limit to your own stuff
  ####
  def mutate_upsert_upload_file(%{file: _} = args, info) do
    with_current_user(info, "upsertUpload.File", fn _user ->
      Upload.Files.upsert_file(args)
    end)
  end

  ##############################################################################
  def mutate_delete_upload_file(%{id: id}, info) do
    with_current_user(info, "deleteUpload.File", fn _user ->
      with {:ok, record} <- Upload.Files.one(id: id) do
        Upload.Files.cleanup_invalid()
        Upload.Files.delete_file(record)
      else
        _ ->
          {:error, "cannot find upload with id=#{id}"}
      end
    end)
  end
end
