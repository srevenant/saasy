defmodule Core.Model.CollectionIntId do
  @moduledoc """
  Domain context for accessing and working with __MODULE__ in the system.
  """
  use Core.Context

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @model Keyword.get(opts, :model)
      use Core.Model.Collection, model: @model
      @type id :: integer

      ##########################################################################
      @spec one!(id | Keyword.t()) :: nil | @model.t()
      def one!(id) when is_integer(id), do: one!([id: id], [])
      def one!(id, preload) when is_integer(id) and is_list(preload), do: one!([id: id], preload)
      def one!(any, preload_atom) when is_atom(preload_atom), do: one!(any, [preload_atom])
      def one!(clauses) when is_list(clauses), do: one!(clauses, [])

      def one!(clauses, preload) when is_list(clauses) and is_list(preload) do
        Repo.one!(from(@model, where: ^clauses, preload: ^preload))
      rescue
        err -> {:error, err}
      end

      ##########################################################################
      @spec one(id | Keyword.t(), List.t() | Atom.t()) ::
              {:ok, @model.t()} | {:error, %Ecto.Changeset{}}
      def one(id) when is_integer(id), do: one([id: id], [])
      def one(id, preload) when is_integer(id) and is_list(preload), do: one([id: id], preload)
      def one(any, preload_atom) when is_atom(preload_atom), do: one(any, [preload_atom])
      def one(clauses) when is_list(clauses), do: one(clauses, [])

      def one(clauses, preload) when is_list(clauses) and is_list(preload) do
        case Repo.one(from(@model, where: ^clauses, preload: ^preload)) do
          nil -> {:error, "Nothing found"}
          result -> {:ok, result}
        end
      rescue
        err -> {:error, err}
      end
    end
  end
end
