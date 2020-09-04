defmodule Utils.String.Tags do
  alias __MODULE__

  defstruct all: %{},
            end: %{}

  @type t :: %Tags{
          all: Map.t(),
          end: Map.t()
        }
end

defmodule Utils.String do
  alias Utils.String.Tags
  import Utils.Types, only: [to_atom: 1]

  @moduledoc """
  Helper module for common String handling needs
  """

  @doc ~S"""
  Trim key=value pairs from end of string

    iex> trim_kv("test key1=value key2=\"quoted value\" key3=value=moar key4=value+more")
    {"test", %{"key1" => "value", "key2" => "quoted value", "key3" => "value=moar", "key4" => "value+more"}}

    iex> trim_kv("test key=first key=\"quoted second\" key=moar key=+more")
    {"test", %{"key" => "first"}}

    iex> trim_kv("this string has key=value pairs=\"with longer strings\"")
    {"this string has", %{"key" => "value", "pairs" => "with longer strings"}}

    iex> trim_kv("it only=removes kv pairs from end=of the=string")
    {"it only=removes kv pairs from", %{"end" => "of", "the" => "string"}}
  """
  def trim_kv(string, vals \\ %{})
  def trim_kv("", vals), do: {"", vals}

  def trim_kv(string, vals) when is_map(vals) do
    case Regex.run(~r/\s*([A-Za-z0-9_-]+)=([^ "]+|"((?:[^"\\]|\\.)*)")\s*$/, string,
           return: :index
         ) do
      nil ->
        {string, vals}

      [{all1, _}, {_, _} = k, {_, _} = v] ->
        trim_kv_slice(string, vals, all1, k, v)

      [{all1, _}, {_, _} = k, _, {_, _} = v] ->
        trim_kv_slice(string, vals, all1, k, v)
    end
  end

  defp trim_kv_slice(string, vals, allx, {key1, key2}, {val1, val2}) do
    newstr = String.slice(string, 0, allx)
    key = String.slice(string, key1, key2)
    val = String.slice(string, val1, val2)
    trim_kv(newstr, Map.put(vals, key, val))
  end

  @doc ~S"""
  Add key=value pairs back to string

    iex> add_kv("test", %{"key1" => "value", "key2" => "quoted value", "key3" => "value=moar", "key4" => "value+more"})
    "test key1=value key2=\"quoted value\" key3=value=moar key4=value+more"

    iex> add_kv("this string has", %{"key" => "value", "pairs" => "with longer strings"})
    "this string has key=value pairs=\"with longer strings\""

    iex> add_kv("it only=removes kv pairs from", %{"end" => "of", "the" => "string"})
    "it only=removes kv pairs from end=of the=string"
  """
  def add_kv(string, vals) when is_map(vals) do
    Enum.reduce(Map.keys(vals), [string], fn key, acc ->
      [acc | [" ", key, "=", add_kv_value(vals[key])]]
    end)
    |> IO.iodata_to_binary()
  end

  defp add_kv_value(str) when is_binary(str) do
    if String.contains?(str, " ") or String.contains?(str, "\"") do
      "#{inspect(str)}"
    else
      str
    end
  end

  # utilities for use w/{trim/find}_tags
  defp trim_put(nil, value) do
    MapSet.new([value])
  end

  defp trim_put(mapset, value) do
    MapSet.put(mapset, value)
  end

  @doc ~S"""
  Extract and Trim # and @ tags (only trim if they are at end)

    iex> trim_tags("test")
    {"test", %Utils.String.Tags{}}

    iex> trim_tags("test #th1 #th2 not #eth1 #eth2")
    {"test #th1 #th2 not", %Utils.String.Tags{ all: %{"#": MapSet.new(["#eth1", "#eth2", "#th1", "#th2"])}, end: %{"#": MapSet.new(["#eth1", "#eth2"])}}}

    iex> trim_tags("test @ta1 @ta2 #th1 #th2 ~tt1 ~tt2 !tb1 !tb2 not @eta1 @eta2 #eth1 #eth2 ~ett1 ~ett2 !etb1 !etb2")
    {"test @ta1 @ta2 #th1 #th2 ~tt1 ~tt2 !tb1 !tb2 not", %Utils.String.Tags{ all: %{!: MapSet.new(["!etb1", "!etb2", "!tb1", "!tb2"]), "#": MapSet.new(["#eth1", "#eth2", "#th1", "#th2"]), @: MapSet.new(["@eta1", "@eta2", "@ta1", "@ta2"]), "~": MapSet.new(["~ett1", "~ett2", "~tt1", "~tt2"])}, end: %{!: MapSet.new(["!etb1", "!etb2"]), "#": MapSet.new(["#eth1", "#eth2"]), @: MapSet.new(["@eta1", "@eta2"]), "~": MapSet.new(["~ett1", "~ett2"])}}}

  """
  def trim_tags(string, tags \\ %Tags{})
  def trim_tags("", tags), do: {"", tags}

  def trim_tags(string, tags) do
    case Regex.run(~r/\s*(([@#~!])[A-Za-z0-9_-]+)\s*$/, string, return: :index) do
      nil ->
        find_tags(string, tags)

      [{begin, _}, {tag1, tag2}, {type1, type2}] ->
        newstr = String.slice(string, 0, begin)
        type = to_atom(String.slice(string, type1, type2))
        tag = String.slice(string, tag1, tag2)

        trim_tags(
          newstr,
          %Tags{
            tags
            | all: Map.put(tags.all, type, trim_put(tags.all[type], tag)),
              end: Map.put(tags.end, type, trim_put(tags.end[type], tag))
          }
        )

      match ->
        IO.inspect(match, label: "MATCH")
        {string, tags}
    end
  end

  def find_tags(string, tags \\ %Tags{}) do
    result = Regex.scan(~r/\s*(([@#~!])[A-Za-z0-9_-]+)\s*/, string)

    tags =
      Enum.reduce(result, tags, fn key, acc ->
        with [_, tag, type] <- key do
          type = to_atom(type)
          %Tags{acc | all: Map.put(acc.all, type, trim_put(acc.all[type], tag))}
        end
      end)

    {string, tags}
  end

  @doc ~S"""
  Enrich a string with # and @ tags, based on %Tags{} struct

    iex> tags = %{"#": MapSet.new(["#eth1", "#eth2", "#th1", "#th2"])}
    ...> add_tags("test #eth1 tardis", tags)
    "test #eth1 tardis #eth2 #th1 #th2"

    iex> tags = %{!: MapSet.new(["!etb1", "!etb2", "!tb1", "!tb2"]), "#": MapSet.new(["#eth1", "#eth2", "#th1", "#th2"]), @: MapSet.new(["@eta1", "@eta2", "@ta1", "@ta2"]), "~": MapSet.new(["~ett1", "~ett2", "~tt1", "~tt2"])}
    ...> add_tags("test !tb1 ~ett2 #eth1 !th2 tardis", tags)
    "test !tb1 ~ett2 #eth1 !th2 tardis !etb1 !etb2 !tb2 #eth2 #th1 #th2 @eta1 @eta2 @ta1 @ta2 ~ett1 ~tt1 ~tt2"

  """
  def add_tags(string, tags \\ %{})
  def add_tags("", tags), do: {"", tags}

  def add_tags(string, tags) do
    # scan string for existing tags, creating set of missed ones
    Enum.reduce(tags, MapSet.new([]), fn {_key, val}, acc ->
      Enum.reduce(MapSet.to_list(val), acc, fn tag, inacc ->
        if !String.contains?(string, tag <> " ") do
          MapSet.put(inacc, tag)
        else
          inacc
        end
      end)
    end)
    |> MapSet.to_list()
    |> Enum.reduce([string], fn tag, acc ->
      [acc | [" ", tag]]
    end)
    |> IO.iodata_to_binary()
  end

  ## BJG: come back to this later: it's supposed to do: count("this.string.k", ".") => 2
  # pulled the tail recursion from a stack overflow, but it's not the right type of accumulator
  # if it's a dict, tbd...
  #  defp count(string, char, acc \\ 0)
  #  defp count("", char, acc), do: acc
  #  defp count(<<head::utf8, tail::binary>>, char, acc) do
  #    defp _count(<<head::utf8, tail::binary>>, acc \\ %{}) do
  #
  #    count(tail, Map.update(acc, <<head>>, 1, &(&1 + 1)))
  #  end

  def validate_uri(str) do
    uri = URI.parse(str)

    case uri do
      %URI{scheme: nil} -> {:error, uri}
      %URI{host: nil} -> {:error, uri}
      uri -> {:ok, uri}
    end
  end
end
