defmodule CoreHealthStatusTest do
  use Core.Case
  doctest Core.HealthStatus, import: true

  test "health status" do
    assert Core.HealthStatus.status(%{}) == :ok
    assert Core.HealthStatus.status(%{detail: "true"}) == :ok
  end
end
