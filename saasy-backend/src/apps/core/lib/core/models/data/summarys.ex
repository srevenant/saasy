defmodule Core.Model.Summarys do
  use Core.Context
  use Core.Model.CollectionIntId, model: Core.Model.Summary

  def no_latest(type) do
    from(s in Summary, where: s.latest == true and s.type == ^type)
    |> Repo.update_all(set: [latest: false])
  end

  def add(type, value) when is_atom(type) and is_map(value) do
    no_latest(type)

    create(%{
      latest: true,
      type: type,
      value: value
    })
  end

  def latest(type) do
    {:ok,
     from(s in Summary, where: s.latest == true and s.type == ^type)
     |> Repo.all()}
  end
end
