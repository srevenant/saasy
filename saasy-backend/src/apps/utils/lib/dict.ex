defmodule Utils.Dict do
  @moduledoc """
  Utilities for working on dictionaries / maps.  Using dict to avoid any
  conflict/confusion with map operations.
  """

  @doc """
  MOVE a value from one dictionary to another (left to right).
  Useful for recursive cleaning of dictionary arg lists.

  iex> dmove(%{a: 1, key: 10}, %{}, :key)
  {%{a: 1}, %{key: 10}}
  iex> dmove(%{a: 1, key: 10}, %{key: 4}, :key)
  {%{a: 1}, %{key: 10}}
  iex> dmove(%{a: 1, key: 10}, %{key: 4}, :key, 30)
  {%{a: 1}, %{key: 30}}
  """
  def dmove(dsrc, ddst, key) do
    {
      Map.delete(dsrc, key),
      Map.put(ddst, key, Map.get(dsrc, key))
    }
  end

  def dmove(dsrc, ddst, key, value) do
    {
      Map.delete(dsrc, key),
      Map.put(ddst, key, value)
    }
  end

  @doc """
  COPY a value from one dictionary to another (left to right).
  Useful for recursive cleaning of dictionary arg lists.

  iex> dcopy(%{a: 1, key: 10}, %{}, :key)
  {%{a: 1, key: 10}, %{key: 10}}
  iex> dcopy(%{a: 1, key: 10}, %{key: 4}, :key)
  {%{a: 1, key: 10}, %{key: 10}}
  iex> dcopy(%{a: 1, key: 10}, %{key: 4}, :key, 30)
  {%{a: 1, key: 10}, %{key: 30}}
  """
  def dcopy(dsrc, ddst, key) do
    {
      dsrc,
      Map.put(ddst, key, Map.get(dsrc, key))
    }
  end

  def dcopy(dsrc, ddst, key, value) do
    {
      dsrc,
      Map.put(ddst, key, value)
    }
  end
end
