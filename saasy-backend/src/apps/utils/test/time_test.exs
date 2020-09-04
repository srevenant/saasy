defmodule UtilsTimeTest do
  use ExUnit.Case
  doctest Utils.Time, import: true
  alias Utils.Time

  test "time_range" do
    now = DateTime.utc_now()

    Enum.each(
      [
        ["1d", 86400],
        ["2.5 days", 216_000],
        ["2.5h", 9000],
        ["2h", 7200],
        ["20m", 1200],
        ["20min", 1200],
        ["20 min", 1200],
        ["20", 1200],
        # because we round to a minute
        ["20s", 0],
        # because we round to a minute
        ["120s", 120],
        ["8:45 am", 0],
        ["8:45a", 0],
        ["8:45p", 0],
        ["10:25a+5min", 300],
        ["10:25p + 1 hours", 3600],
        ["10:25a - 14:20", 14100],
        ["12:00-13:30", 5400]
      ],
      fn arg ->
        [input, elapsed] = arg
        {:ok, _d1, _d2, seconds} = Time.time_range(input, now)
        assert elapsed == seconds
      end
    )

    {:ok, time1, _} = DateTime.from_iso8601("#{DateTime.to_date(DateTime.utc_now())} 12:00:00Z")
    {:ok, time2, _} = DateTime.from_iso8601("#{DateTime.to_date(DateTime.utc_now())} 15:30:00Z")
    assert {:ok, time1, time2, 12600} == Time.time_range("12:00-3:30")
  end
end
