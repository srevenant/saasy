defmodule UtilsJsonConfigProviderTest do
  use ExUnit.Case
  doctest Utils.JsonConfigProvider, import: true

  @testfile "./__json_test_config_.json"
  @testdata """
  {"web":{"tardis":"blue", "Elixir.Utils.JsonConfigProvider": {"sub": "key"}}}
  """
  def cleanup() do
    File.rm!(@testfile)
  end

  setup do
    on_exit(&cleanup/0)
  end

  test "config provider" do
    assert Application.get_env(:web, :tardis) == nil
    assert File.write!(@testfile, @testdata) == :ok
    assert Utils.JsonConfigProvider.init(path: @testfile) == :ok
    assert Application.get_env(:web, :tardis) == "blue"
    assert Application.get_env(:web, Utils.JsonConfigProvider) == [{:sub, "key"}]
  end
end
