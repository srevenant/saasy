defmodule Utils.FiltersTest do
  use ExUnit.Case
  alias Utils.Filters
  doctest Utils.Filters

  setup %{} do
    filters = [
      %{attribute: "hasBoolean", comparison: :is_null, value: "false"},
      %{attribute: "isNumber", comparison: :greater_than, value: "1"},
      %{attribute: "name", comparison: :contains, value: "a"}
    ]

    {:ok, %{filters: filters}}
  end

  describe "concerning reduce" do
    test "it reduces an input list of maps", %{filters: filters} do
      expected = [
        has_boolean: {:is_null, false},
        is_number: {:greater_than, "1"},
        name: {:contains, "a"}
      ]

      assert expected == Filters.reduce(filters)
    end
  end
end
