defmodule Core.TestDefinitions do
  defmacro __using__(_) do
    quote do
      @test_hostname_old "test-host"
    end
  end
end
