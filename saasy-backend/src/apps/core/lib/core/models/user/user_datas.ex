defmodule Core.Model.UserDatas do
  use Core.Context
  use Core.Model.CollectionUuid, model: Core.Model.UserData

  def list_types(%User{id: id}, types) when is_list(types) do
    Repo.all(
      from(d in UserData,
        where: d.user_id == ^id and d.type in ^types
      )
    )
  end
end
