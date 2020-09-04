defmodule Core.Model.RoleMaps do
  use Core.Context
  use Core.Model.CollectionIntId, model: Core.Model.RoleMap

  def get_actions(role_id) when is_integer(role_id) do
    case Core.RoleCache.lookup(role_id) do
      [{_role_name, actions, _}] ->
        actions

      _no_cache ->
        actions =
          RoleMaps.all!(role_id: role_id)
          |> Repo.preload(:action)
          |> Enum.map(fn e -> e.action.name end)

        Core.RoleCache.insert(role_id, actions, 300_000)
        actions
    end
  end
end
