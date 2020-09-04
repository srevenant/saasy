defmodule Utils.Dig do
  import Utils.Types, only: [to_atom: 1]

  def dig(nil, _), do: nil

  # assume atom keys
  def dig(item, keys) when is_binary(keys) do
    dig(item, String.split(keys, ".") |> Enum.map(fn key -> to_atom(key) end))
  end

  def dig(item, [head | tail]) do
    item
    |> Map.get(head)
    |> dig(tail)
  end

  def dig(item, []), do: item
end
