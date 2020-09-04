defmodule Web.Absinthe do
  @moduledoc """
  Helper functions to user with the GraphQL pipeline. Helpers for resolvers.
  """
  require Logger
  use Core.ContextClient
  alias Absinthe.Resolution

  ##############################################################################
  defp with__call_func_handler(func, method, args) when is_function(func) do
    if not is_nil(method) do
      graphql_log(method)
    end

    func.(args)
  end

  # defp with__call_func_handler(func, args) when is_function(func), do: func.(args)
  #   case func.(args) do
  #     {:error, msg} when is_binary(msg) ->
  #       {:error, msg}
  #
  #     # {:error, message: msg, errorMessage: msg}
  #
  #     # TODO: other conditions to wrap
  #     result ->
  #       result
  #   end
  # end

  ##############################################################################
  @doc """
  Handles extracting the current user from the Absinthe context, and then will
  either call `func` and pass in the current user or return an error if there is
  no user in the context
  """
  def with_current_user(info, arg1, arg2 \\ nil, arg3 \\ nil)
  # def with_current_user(info, method, good_func, bad_func \\ nil)

  # with user is good
  def with_current_user(%Absinthe.Resolution{context: %{user: %User{} = u}}, good, _, nil)
      when is_function(good),
      do: good.(u)

  # without user is bad
  def with_current_user(_, good, bad, nil) when is_function(good) and is_function(bad),
    do: bad.(nil)

  def with_current_user(_, good, _, nil) when is_function(good), do: graphql_error(nil, :authn)

  # when method exists, it also logs -- preferred method
  def with_current_user(%Absinthe.Resolution{context: %{user: %User{} = user}}, method, good, _)
      when is_function(good),
      do: with__call_func_handler(good, method, user)

  def with_current_user(_no_user, method, _, bad) when is_function(bad),
    do: with__call_func_handler(bad, method, nil)

  def with_current_user(_, method, _, _), do: graphql_error(method, :authn)

  ##############################################################################
  def with_authz_action(user, action, method, success, failure \\ nil)

  def with_authz_action(
        %Absinthe.Resolution{context: %{user: %User{} = user}},
        action,
        method,
        success,
        failure
      )
      when not is_nil(user) and is_atom(action) and is_binary(method),
      do: with_authz_action(user, action, method, success, failure)

  def with_authz_action(%User{} = user, action, method, success, failure)
      when is_atom(action) and is_binary(method) do
    with {has_authz, user} <- Users.check_authz(user, action) do
      if has_authz do
        with__call_func_handler(success, method, user)
      else
        if is_nil(failure) do
          graphql_error(method, :authz)
        else
          with__call_func_handler(failure, method, user)
        end
      end
    end
  end

  # pass through with no auth checking if action is nil
  def with_authz_action(_, action, method, func, _) when is_nil(action) and is_binary(method),
    do: with__call_func_handler(func, method, nil)

  def with_authz_action(_, action, method, _, _) when is_atom(action) and is_binary(method) do
    graphql_error(method, :authn)
  end

  ##############################################################################
  # mostly to create a uniform pattern, incase in the future we want to log
  # success/failures too
  def with_logging(info, method, func),
    do: with_tenant(info, method, func)

  # ????
  #  def with_logging(%Absinthe.Resolution{context: %{user: %User{} = user}}, _, func) do
  #    func.(user)
  #  end

  #  def with_logging(_, method, func) do
  #    graphql_log(method)
  #    func.(nil)
  #  end

  ##############################################################################
  def with_tenant(%Absinthe.Resolution{context: %{tenant: tenant}}, method, func)
      when not is_nil(tenant),
      do: with__call_func_handler(func, method, tenant)

  def with_tenant(%Absinthe.Resolution{context: _res}, method, _f),
    do: graphql_error(method, "Tenant Missing - Bad DB Configuration?")

  # no logging
  def with_tenant(%Absinthe.Resolution{context: %{tenant: tenant}}, func)
      when not is_nil(tenant),
      do: func.(tenant)

  ##############################################################################
  def optional_arg(map, arg) do
    case Map.get(map, arg) do
      nil -> []
      value -> [{arg, value}]
    end
  end

  ##############################################################################
  # the ones with Atoms are just to standardize errors
  @std_errors %{authn: "Unauthenticated", authz: "Unauthorized"}
  def error_string(errs) when is_list(errs) do
    Enum.map(errs, &error_string/1)
    |> Enum.join(",")
  end

  def error_string(%Ecto.Changeset{} = chgset), do: Utils.Errors.convert_error_changeset(chgset)
  def error_string(reason) when is_atom(reason), do: @std_errors[reason]
  def error_string(reason) when is_binary(reason), do: reason

  def graphql_result({:ok, _} = pass, _), do: pass
  def graphql_result({:error, reason}, method), do: graphql_error(method, reason)

  def graphql_status_result(state, method \\ nil)

  def graphql_status_result({:error, "Unauthenticated"} = pass, _), do: pass
  def graphql_status_result({:ok, %{success: a}} = pass, _) when is_boolean(a), do: pass
  def graphql_status_result({:ok, result}, _), do: {:ok, %{success: true, result: result}}

  def graphql_status_result({:error, err}, _),
    do: {:ok, %{success: false, reason: error_string(err)}}

  def graphql_error(method, err, logargs \\ []) do
    reason = error_string(err)
    graphql_log(method, [failure: reason] ++ logargs)
    {:error, reason}
  end

  ##############################################################################
  def graphql_log(method, kwargs \\ []) do
    Logger.info("graphql", [method: method] ++ kwargs)
  end

  ##############################################################################
  # generic edit

  # 4 args: without auth action
  def mutate_upsert({:error, _} = pass, _, _, _), do: pass

  def mutate_upsert(%{id: id} = args, method, module, info)
      when is_map(info) and (is_binary(id) or is_integer(id)),
      do: module.replace(args, id: id) |> graphql_status_result(method)

  def mutate_upsert(args, method, module, info)
      when is_map(info),
      do: module.create(args) |> graphql_status_result(method)

  # 5 args: with an auth action
  def mutate_upsert({:error, _} = pass, _, _, _, _), do: pass
  def mutate_upsert({:ok, arg}, a, b, c, d), do: mutate_upsert(arg, a, b, c, d)

  def mutate_upsert(args, method, module, auth_action, info) when is_atom(auth_action) do
    with_authz_action(info, auth_action, method, fn _ ->
      mutate_upsert(args, method, module, info)
    end)
  end

  # # generic create
  # def mutate_upsert(args, method, module, auth_action, info) when is_atom(auth_action) do
  #   with_authz_action(info, auth_action, method, fn _ ->
  #     module.create(args)
  #     |> graphql_status_result(method)
  #   end)
  # end

  ##############################################################################
  def put_context(%Resolution{} = res, merge) when is_map(merge) do
    %Resolution{res | context: Map.merge(res.context, merge)}
  end

  def put_context(%Resolution{} = res, key, value) when is_atom(key) do
    %Resolution{res | context: Map.put(res.context, key, value)}
  end
end
