defmodule Core.Model.SummaryUsers do
  use Core.Context
  use Core.Model.CollectionIntId, model: Core.Model.SummaryUser

  def all_of_type(%User{} = user, types), do: all_of_type(user.id, types)

  def all_of_type(user_id, types) when is_binary(user_id) and is_list(types) do
    {:ok,
     Repo.all(
       from(s in SummaryUser,
         where: s.user_id == ^user_id and s.type in ^types
       )
     )}
  rescue
    _ in Ecto.Query.CastError ->
      {:error, "Invalid type in types list"}

    err ->
      {:error, Utils.Errors.convert_error_changeset(err)}
  end
end
