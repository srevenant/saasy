defmodule Core.Model.CollectionModel do
  @moduledoc """
  Domain context for accessing and working with __MODULE__ in the system.
  """
  use Core.Context

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @model Keyword.get(opts, :collection)

      # @doc """
      # Restore a record, including it's primary key. primarily this is only for
      # doing data imports where you need to preserve the primary key
      # """
      # def build_restore(attrs) do
      #   struct(%__MODULE__{}, Utils.Types.atom_keys(attrs))
      # end
      # def build_restore(_), do: nil
      def change_prep(i, p), do: {:ok, p}
      def change_post(i, p), do: i
    end
  end
end
