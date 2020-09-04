defmodule Utils.Types do
  @moduledoc """
  Helper module for common type handling needs
  """

  @doc ~S"""
  String to int with idiomatic stack error handling

  ## Examples

      iex> str_to_int(10)
      {:ok, 10}
      iex> str_to_int("10")
      {:ok, 10}
      iex> str_to_int("tardis")
      {:error, "\"tardis\" is not a number"}
  """
  def str_to_int(arg) when is_integer(arg), do: {:ok, arg}

  def str_to_int(arg) when is_binary(arg) do
    {:ok, String.to_integer(arg)}
  rescue
    ArgumentError -> {:error, "#{inspect(arg)} is not a number"}
  end

  def str_to_int!(arg, default) do
    case str_to_int(arg) do
      {:ok, num} -> num
      {:error, _} -> default
    end
  end

  @doc ~S"""
  String to float with idiomatic stack error handling

  ## Examples

      iex> str_to_float("10.5")
      {:ok, 10.5}
      iex> str_to_float(".55")
      {:ok, 0.55}
      iex> str_to_float("tardis")
      {:error, "\"tardis\" is not a number"}
  """
  def str_to_float(arg) when is_number(arg), do: arg

  def str_to_float(arg) when is_binary(arg) do
    {:ok, String.to_float(arg)}
  rescue
    ArgumentError ->
      if String.at(arg, 0) == "." do
        str_to_float("0#{arg}")
      else
        str_to_int(arg)
      end
  end

  @doc ~S"""
  return the result as an integer, where input is either an int or a string.
  errors are returned for anything else

  ## Examples

      iex> as_int!("10")
      10
      iex> as_int!("tardis")
      ** (ArgumentError) "tardis" is not a number

  """
  def as_int!(input) when is_integer(input), do: input

  def as_int!(input) when is_binary(input) do
    String.to_integer(input)
  rescue
    ArgumentError -> raise ArgumentError, message: "#{inspect(input)} is not a number"
  end

  def as_int!(input) do
    raise ArgumentError, message: "#{inspect(input)} cannot become a number"
  end

  @doc """
  Iterate a map and merge string & atom keys into just strings.

  Not recursive, only top level.

  Behavior with mixed keys being merged is not guaranteed, as maps are not always
  ordered.

  ## Examples

      iex> string_keys(%{tardis: 1, is: 2, color: "blue"})
      %{"tardis" => 1, "is" => 2, "color" => "blue"}

  """
  def string_keys(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {to_string(key), val}
        true -> {key, val}
      end
    end
  end

  @doc """
  Iterate a map and merge string & atom keys into just atoms.
  Not recursive, only top level.
  Behavior with mixed keys being merged is not guaranteed, as maps are not always
  ordered.

  ## Examples

      iex> atom_keys(%{"tardis" => 1, "is" => 2, "color" => "blue"})
      %{tardis: 1, is: 2, color: "blue"}

  """
  def atom_keys(map, opts \\ nil)

  def atom_keys(map, nil) when is_map(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, val}
        true -> {to_atom(key), val}
      end
    end
  end

  @doc """
  Go deep, and use clean_atom which will mangle things
  """
  def atom_keys(map, clean: true) when is_map(map) do
    for {key, val} <- map, into: %{} do
      key = clean_atom(key)

      cond do
        is_list(val) ->
          {key,
           Enum.map(val, fn elem ->
             cond do
               is_map(elem) -> atom_keys(elem, clean: true)
               true -> elem
             end
           end)}

        is_map(val) ->
          {key, atom_keys(val, clean: true)}

        true ->
          {key, val}
      end
    end
  end

  def atom_keys(list, opts) when is_list(list) do
    Enum.map(list, fn elem -> atom_keys(elem) end)
  end

  @doc """
  Get an atom, preferably using to_existing_atom, unless the atom doesn't exist,
  just don't throw an error.

    iex> to_atom("long ugly thing prolly")
    :"long ugly thing prolly"
    iex> to_atom("long ugly thing prolly")
    :"long ugly thing prolly"
    iex> to_atom("to_atom")
    :to_atom
  """
  def to_atom(str) when is_binary(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError ->
      String.to_atom(str)
  end

  def to_atom(list) when is_list(list) do
    Enum.map(list, fn key -> to_atom(key) end)
  end

  def to_atom(key) when is_atom(key), do: key

  @doc """
  Remove nil values from a map

    iex> remove_nils_from_map(%{first: 1, second: nil, third: 3})
    %{first: 1, third: 3}
    iex> remove_nils_from_map(%{first: 1, third: 3})
    %{first: 1, third: 3}
  """
  def remove_nils_from_map(map) do
    :maps.filter(fn _, v -> !is_nil(v) end, map)
  end

  ################################################################################
  @doc """
  Lowercase, Snakecase atom, from string or atom

  iex> clean_atom(:value)
  :value

  iex> clean_atom(:Value)
  :value

  iex> clean_atom(:"value-dashed")
  :value_dashed

  iex> clean_atom("VALUE-dashed")
  :value_dashed
  """
  def clean_atom(value) when is_atom(value) do
    clean_atom(Atom.to_string(value))
  end

  def clean_atom(value) when is_binary(value) do
    String.downcase(value) |> String.replace("-", "_") |> to_atom
  end

  def clean_atom(value), do: value

  ################################################################################
  def map_to_kvstr(map) do
    Enum.join(
      Enum.map(map, fn {k, v} ->
        [any_to_string(k), "=", any_to_string(v)]
      end),
      " "
    )
  end

  defp json_safe_string(str) when is_binary(str) do
    if String.contains?(str, " ") or String.contains?(str, "\"") do
      "#{inspect(str)}"
    else
      to_string(str)
    end
  end

  defp any_to_string(pid) when is_pid(pid) do
    :erlang.pid_to_list(pid)
    |> json_safe_string
  end

  defp any_to_string(ref) when is_reference(ref) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)

    rest
    |> json_safe_string
  end

  defp any_to_string(str) when is_binary(str) do
    json_safe_string(str)
  end

  defp any_to_string(atom) when is_atom(atom) do
    case Atom.to_string(atom) do
      "Elixir." <> rest -> rest
      "nil" -> ""
      binary -> binary
    end
    |> json_safe_string
  end

  defp any_to_string(other) do
    any_to_string(Kernel.inspect(other))
  end

  @doc ~S"""
  Remove any keys not in allowed_keys list
  iex> strip_keys_not_in(%{"this" => 1, "that" => 2}, ["this"])
  %{"this" => 1}
  """
  def strip_keys_not_in(dict, allowed_keys) when is_map(dict) and is_list(allowed_keys) do
    Enum.reduce(Map.keys(dict) -- allowed_keys, dict, fn badkey, acc ->
      Map.delete(acc, badkey)
    end)
  end

  @doc ~S"""
  iex> strip_values_not_is(%{"a" => false, "b" => "not bool"}, &is_boolean/1)
  %{"a" => false}
  """
  def strip_values_not_is(dict, type_test) when is_map(dict) and is_function(type_test) do
    Enum.reduce(Map.keys(dict), dict, fn key, acc ->
      if type_test.(Map.get(acc, key)) do
        acc
      else
        Map.delete(acc, key)
      end
    end)
  end

  @doc ~S"""
  iex> strip_subdict_values_not(%{"sub" => %{"a" => false, "b" => "not bool"}}, "sub", &is_boolean/1)
  %{"sub" => %{"a" => false}}
  """
  def strip_subdict_values_not(dict, key, type_test) do
    Map.put(dict, key, strip_values_not_is(Map.get(dict, key, %{}), type_test))
  end
end
