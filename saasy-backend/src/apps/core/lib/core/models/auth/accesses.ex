defmodule Core.Model.Accesses do
  use Core.Context
  use Core.Model.CollectionIntId, model: Core.Model.Access

  @doc """
  Fold a list of accesses into a set of actions, using memory cache
  """
  @spec get_actions(accesses :: list()) :: MapSet.t()
  def get_actions(accesses) when is_list(accesses) do
    ## TODO: switch this to a joined SELECT - ecto-fu or direct SQL
    Enum.map(accesses, fn a ->
      RoleMaps.get_actions(a.role_id)
    end)
    |> Enum.concat()
    |> MapSet.new()
  end

  # @spec get_subscriptions(accesses :: list()) :: MapSet.t()
  # def get_subscriptions(accesses) when is_list(accesses) do
  #   ## TODO: switch this to a joined SELECT - ecto-fu
  #   MapSet.new(
  #     Enum.reduce(accesses, [], fn access, acc ->
  #       case Accesses.preload(access, [:role]) do
  #         {:ok, %Access{role: %Role{subscription: true}}} ->
  #           acc ++ RoleMaps.get_actions(access.role_id)
  #
  #         {:ok, _} ->
  #           acc
  #       end
  #     end)
  #   )
  # end

  def add(%User{} = user, role_atom) when is_atom(nil) do
    case Roles.one(name: role_atom) do
      {:ok, role} ->
        Accesses.upsert(%{role_id: role.id, user_id: user.id})

      _ ->
        {:error, "cannot find role #{role_atom}"}
    end
  end

  def drop(%User{} = user, role_atom) when is_atom(nil) do
    case Roles.one(name: role_atom) do
      {:ok, role} ->
        case Accesses.one(role_id: role.id, user_id: user.id) do
          {:ok, access} ->
            Accesses.delete(access)

          _ ->
            {:error, "cannot find access link"}
        end

      {:error, _} ->
        {:error, "cannot find role #{role_atom}"}
    end
  end

  def delete_by_user(user_id) do
    {:ok, Repo.delete_all(from(a in Access, where: a.user_id == ^user_id))}
  end
end
