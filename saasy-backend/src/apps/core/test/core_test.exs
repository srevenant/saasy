defmodule CoreTest do
  use Core.Case
  doctest Core

  test "greets the world" do
    assert Core.hello() == :world
  end
end
