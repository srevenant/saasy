defmodule Utils.Enum do
  # TODO: Move this somewhere else
  @doc """
  like Enum.find_value() on a list of [{rx, fn}, ..], calling fn on the matched
  rx and returning the result.  Almost like a case statement (see to_minutes below)

  iex> opts = [
  ...>   {~r/^(\\d+)\\s*(m|min(s)?|minute(s)?)$/, fn match, _ -> {:min, match} end},
  ...>   {~r/^(\\d+)\\s*(h|hour(s)?|hr(s)?)$/, fn match, _ -> {:hr, match} end},
  ...> ]
  ...> enum_rx(opts, "30 m")
  {:min, ["30 m", "30", "m"]}
  iex> enum_rx(opts, "1.5 hr") # doesn't match because of the period
  nil
  """
  def enum_rx([], _str), do: nil

  def enum_rx(elems, str) do
    [elem | elems] = elems
    {rx, func} = elem

    case Regex.run(rx, str) do
      nil ->
        enum_rx(elems, str)

      match ->
        func.(match, str)
    end
  end
end
