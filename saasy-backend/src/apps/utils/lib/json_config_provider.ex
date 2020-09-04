defmodule Utils.JsonConfigProvider do
  @moduledoc """
  Derived from toml-elixir/Toml.Provider https://github.com/bitwalker/toml-elixir/blob/master/lib/provider.ex

  This is a runtime config provider (for 12factor apps).

  It will merge json data into the config structure.

  In Elixir Config:
  config :app, That.Module,
    the: thing

  In Elixir (Raw)

  Application.get_env(:app, That.Module)
  [{ the: "thing" }]

  In JSON, you have to prefix 'Elixir.' on the module name:

  {"app": {"Elixir.That.Module": {"the": "thing"}}}
  """
  def init(opts) when is_list(opts) do
    path = Keyword.fetch!(opts, :path)

    with {:ok, expanded} <- expand_path(path),
         {:ok, _} <- check_file_path(expanded),
         {:ok, body} <- File.read(expanded),
         {:ok, cfg} <- Poison.decode(body),
         keyword when is_list(keyword) <- to_keyword(cfg) do
      persist(keyword)
    else
      {:error, :enoent} ->
        exit({:shutdown, "File read failed"})

      {:error, reason} ->
        exit({:shutdown, reason})
    end
  end

  defp check_file_path(file_path) do
    if File.exists?(file_path) do
      {:ok, true}
    else
      {:error, "Invalid file: #{inspect(file_path)}"}
    end
  end

  @doc false
  def get([app | keypath]) do
    config = Application.get_all_env(app)

    case get_in(config, keypath) do
      nil ->
        nil

      val ->
        {:ok, val}
    end
  end

  defp persist(keyword) when is_list(keyword) do
    # For each app
    for {app, app_config} <- keyword do
      # Get base config
      base = Application.get_all_env(app)
      # Deep merge into current config
      merged = deep_merge(base, app_config)
      # Persist key/value pairs for this app
      for {k, v} <- merged do
        Application.put_env(app, k, v, persistent: true)
      end
    end

    :ok
  end

  # At the top level, convert the map to a keyword list of keyword lists
  # Keys with no children (i.e. keys which are not tables) are dropped
  defp to_keyword(map) when is_map(map) do
    for {k, v} <- map, v2 = to_keyword2(v), is_list(v2), into: [] do
      {String.to_atom(k), v2}
    end
  end

  # For all other values, convert tables to keywords
  defp to_keyword2(map) when is_map(map) do
    for {k, v} <- map, v2 = to_keyword2(v), into: [] do
      {String.to_atom(k), v2}
    end
  end

  # And leave all other values untouched
  defp to_keyword2(term), do: term

  defp deep_merge(a, b) when is_list(a) and is_list(b) do
    if Keyword.keyword?(a) and Keyword.keyword?(b) do
      Keyword.merge(a, b, &deep_merge/3)
    else
      b
    end
  end

  defp deep_merge(_k, a, b) when is_list(a) and is_list(b) do
    if Keyword.keyword?(a) and Keyword.keyword?(b) do
      Keyword.merge(a, b, &deep_merge/3)
    else
      b
    end
  end

  defp deep_merge(_k, a, b) when is_map(a) and is_map(b) do
    Map.merge(a, b, &deep_merge/3)
  end

  defp deep_merge(_k, _a, b), do: b

  def expand_path(path) when is_binary(path) do
    case expand_path(path, <<>>) do
      {:ok, p} ->
        {:ok, Path.expand(p)}

      {:error, _} = err ->
        err
    end
  end

  defp expand_path(<<>>, acc),
    do: {:ok, acc}

  defp expand_path(<<?$, ?\{, rest::binary>>, acc) do
    case expand_var(rest) do
      {:ok, var, rest} ->
        expand_path(rest, acc <> var)

      {:error, _} = err ->
        err
    end
  end

  defp expand_path(<<c::utf8, rest::binary>>, acc) do
    expand_path(rest, <<acc::binary, c::utf8>>)
  end

  defp expand_var(bin),
    do: expand_var(bin, <<>>)

  defp expand_var(<<>>, _acc),
    do: {:error, :unclosed_var_expansion}

  defp expand_var(<<?\}, rest::binary>>, acc),
    do: {:ok, System.get_env(acc) || "", rest}

  defp expand_var(<<c::utf8, rest::binary>>, acc) do
    expand_var(rest, <<acc::binary, c::utf8>>)
  end
end
