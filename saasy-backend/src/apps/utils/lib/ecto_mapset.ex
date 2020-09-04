defmodule Ecto.MapSet do
  @moduledoc """
  Custom Type to support MapSet
  """
  @behaviour Ecto.Type

  def type, do: MapSet

  def cast(%MapSet{} = pass), do: pass

  def cast(list) when is_list(list) do
    MapSet.new(list)
  end

  def cast(_), do: :error

  # only support virtual for now
  def load(_), do: :error

  # only support virtual for now
  def dump(_), do: :error
end
