defmodule Util.ConsoleFormatLogger do
  @moduledoc """
  Provide custom log formatting that is Splunk-friendly.
  """
  alias Logger.Formatter

  @spec format(
          level :: Logger.level(),
          message :: Logger.message(),
          timestamp :: Formatter.time(),
          metadata :: Keyword.t()
        ) :: IO.chardata()
  def format(level, message, timestamp, metadata) do
    # Custom formatting logic...

    # Based on Elixir 1.4.5, 1.5.2, 1.6.1 code
    #
    # https://github.com/elixir-lang/elixir/blob/v1.4.5/lib/logger/lib/logger/formatter.ex
    # https://github.com/elixir-lang/elixir/blob/v1.5.2/lib/logger/lib/logger/formatter.ex
    # https://github.com/elixir-lang/elixir/blob/v1.6.1/lib/logger/lib/logger/formatter.ex

    # IO.inspect({level,message,metadata})

    # I really don't like the useless logs of "POST /graphql"
    case Keyword.get(metadata, :module) do
      Plug.Logger ->
        case Enum.at(message, 2) do
          "/graphql" ->
            ""

          _ ->
            do_format(level, message, timestamp, metadata)
        end

      _other ->
        do_format(level, message, timestamp, metadata)
    end
  end

  defp do_format(level, message, timestamp, metadata) do
    {date, time} = timestamp

    Formatter.format_date(date) ++
      space() ++
      Formatter.format_time(time) ++
      space() ++
      message_output(message) ++
      metadata_output([{:level, level} | metadata]) ++
      done()
  end

  #  defp level_output(level) do
  #    ['level', ?=, to_string(level)]
  #  end

  defp space do
    [?\s]
  end

  defp done do
    [?\n]
  end

  defp message_prep(message) when is_list(message) do
    message
    |> IO.iodata_to_binary()
    |> message_prep()
  end

  defp message_prep(message) when is_binary(message) do
    data2txt(message) |> redact_sensitive
    #    Poison.encode(redact_sensitive(message)) do
    #   {:ok, value} ->
    #     value
    #
    #   {:error, reason} ->
    #     inspect(reason)
    # end
  end

  # Regex as a string to satisfy Credo which doesn't like the long regex but
  # expressed that way, it can't be broken up across lines.
  # As a straight regex, it looks like this (minus the line breaks)
  # ~r/(password: \"\S*\",?\s*)|(username: \"\S*\",?\s*)|
  #   (<<"postgres:\/\/\S*">>)|(url: \"postgres:\/\/\S*\"),?\s*/
  #
  # To get the full string, I let IEx tell me what it wanted. Paste the full
  # regex into iex like:
  #     reg = ~r/.../
  #      %{source: source} = reg
  #     source
  #
  @replace_matcher_regex Regex.compile!(
                           "(password: \\\"\\S*\\\",?\\s*)|" <>
                             "(username: \\\"\\S*\\\",?\\s*)|" <>
                             "(<<\"postgres://\\S*\">>)|" <>
                             "(url: \\\"postgres://\\S*\\\"),?\\s*"
                         )

  #  @blacklisted_metadata_keys [:function, :file, :line, :pid, :error_logger, :application]

  # drop the specific key/value matches
  #  @blacklisted_metadata (Inline in function below)

  @doc """
  Given a string message to log, redact any known sensitive data or information.
  Replaces text that matches the pattern with "" so it is just removed.

  Removes the following things:

    * `password: "something"`
    * `username: "something"`
    * `url: "postgres://something"`

  """
  @spec redact_sensitive(message :: String.t()) :: String.t()
  def redact_sensitive(message) do
    Regex.replace(@replace_matcher_regex, message, "", global: true)
  end

  defp metadata_output([]), do: []

  defp metadata_output(meta) do
    meta_hash = Enum.into(meta, %{})
    # process the keywords - inline to support functions
    blacklist = %{
      function: :drop,
      file: {:drop_when_keyval, [:level, :info]},
      line: :drop,
      pid: :drop,
      level: {:drop_from_set, MapSet.new([:info])},
      error_logger: :drop,
      application: :drop,
      module: [
        {:drop_from_set,
         MapSet.new([:phoenix, :plug, :web, :suprvisor, Phoenix.Endpoint.Supervisor])},
        {:run,
         fn _meta_hash, val ->
           List.last(String.split(data2txt(val), "."))
         end}
      ]
    }

    metadata_output_scan([], blacklist, meta_hash, meta)
  end

  defp metadata_output_scan(acc, _blacklist, _meta_hash, []), do: acc

  defp metadata_output_scan(acc, blacklist, meta_hash, [{key, val} | meta_rest]) do
    metadata_output_map(blacklist, meta_hash, key, val)
    |> metadata_output_filter(key, val, acc)
    # tail recursion
    |> metadata_output_scan(blacklist, meta_hash, meta_rest)
  end

  # returns:
  #   -> nil      == keep default value
  #   -> "string" == keep & use this value
  #   -> true     == drop value
  #   -> :drop    == drop value
  defp metadata_output_map(blacklist, meta_hash, key, val) do
    case Map.get(blacklist, key) do
      :drop ->
        :drop

      {:drop_when_keyval, [key2, val2]} ->
        Map.get(meta_hash, key2) == val2

      {:run, func} ->
        func.(meta_hash, val)

      {:drop_from_set, %MapSet{} = set} ->
        MapSet.member?(set, val)

      # do
      #  :drop
      # else
      #  nil
      # end
      nil ->
        nil

      list ->
        metadata_output_submap(list, fn elem ->
          metadata_output_map(Map.put(%{}, key, elem), meta_hash, key, val)
        end)
    end
  end

  defp metadata_output_submap([], _fun), do: nil

  defp metadata_output_submap([elem | list], fun) do
    case fun.(elem) do
      false -> :drop
      nil -> metadata_output_submap(list, fun)
      val -> val
    end
  end

  defp metadata_output_filter(:drop, _key, _def_val, acc), do: acc
  defp metadata_output_filter(true, _key, _def_val, acc), do: acc

  defp metadata_output_filter(false, key, def_val, acc),
    do: metadata_output_filter(data2txt(def_val), key, nil, acc)

  defp metadata_output_filter(nil, key, def_val, acc) do
    metadata_output_filter(data2txt(def_val), key, nil, acc)
  end

  defp metadata_output_filter(val, key, _def_val, acc) when is_binary(val) do
    if String.length(val) > 0 do
      acc ++ [space(), to_string(key), ?=, val]
    else
      acc
    end
  end

  defp metadata_output_filter(_drop, _key, _def_val, acc), do: acc

  # no msg="" logs
  defp message_output([]), do: []

  defp message_output(message) do
    text = message |> message_prep()
    ['msg', ?=, text]
  end

  defp data2txt(pid) when is_pid(pid) do
    :erlang.pid_to_list(pid)
  end

  defp data2txt(ref) when is_reference(ref) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)
    rest
  end

  defp data2txt(str) when is_binary(str) do
    if String.contains?(str, " ") or String.contains?(str, "\"") do
      "#{inspect(str)}"
    else
      to_string(str)
    end
  end

  defp data2txt(atom) when is_atom(atom) do
    case Atom.to_string(atom) do
      "Elixir." <> rest -> rest
      "nil" -> ""
      binary -> binary
    end
  end

  defp data2txt(other), do: data2txt(Kernel.inspect(other))
end
