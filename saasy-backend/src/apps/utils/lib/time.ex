defmodule Utils.Time do
  import Utils.Types, only: [str_to_int!: 2, str_to_float: 1]
  import Utils.Enum, only: [enum_rx: 2]

  def ifloor(number) when is_float(number), do: Kernel.trunc(number)
  def ifloor(number) when is_integer(number), do: number

  # note for future
  # https://hexdocs.pm/nimble_parsec/NimbleParsec.html

  def iso_time_range(input) when is_binary(input) do
    case String.split(input, "/") do
      [stime, etime] ->
        iso_time_range(stime, etime)

      _other ->
        {:error, "Input #{input} is not a valid ISO time range"}
    end
  end

  def iso_time_range(stime, etime) when is_binary(stime) and is_binary(etime) do
    with {:ok, d_stime = %DateTime{}, _offset} <- DateTime.from_iso8601(stime),
         {:ok, d_etime = %DateTime{}, _offset} <- DateTime.from_iso8601(etime) do
      {:ok, d_stime, d_etime, Timex.to_unix(d_etime) - Timex.to_unix(d_stime)}
    else
      %MatchError{} = e ->
        IO.inspect(e, label: "processing time error")
        {:error, "Unable to process time #{stime}/#{etime}"}
    end
  end

  @doc """
  Iterate a map and merge string & atom keys into just atoms.
  Not recursive, only top level.
  Behavior with mixed keys being merged is not guaranteed, as maps are not always
  ordered.

  ## Examples

  iex> {:ok, %DateTime{}, %DateTime{}, elapsed} = time_range("20 min")
  iex> elapsed
  1200
  """
  def time_range(input) do
    time_range(input, DateTime.utc_now())
  end

  def time_range(input, reference = %DateTime{}) do
    # regex list of supported variants
    time_rxs = [
      {~r/^\s*((\d+):(\d+))\s*((p|a)m?)?\s*$/i,
       fn match, _time ->
         stime = time_at_today(match, reference)
         {stime, stime}
       end},
      {~r/^\s*((\d+):(\d+))\s*((p|a)m?)?\s*-\s*(.+)\s*$/i,
       fn match, _time ->
         stime = time_at_today(Enum.slice(match, 0, 6), reference)

         case time_at_today(Enum.at(match, 6), reference) do
           nil ->
             nil

           %DateTime{} = etime ->
             etime =
               if etime < stime do
                 # assume 12hrs left off
                 Timex.shift(etime, hours: 12)
               else
                 etime
               end

             {stime, etime}
         end
       end},
      {~r/^\s*((\d+):(\d+))\s*((p|a)m?)?\s*\+\s*(.+)\s*$/i,
       fn match, _time ->
         stime = time_at_today(Enum.slice(match, 0, 6), reference)

         case time_duration(Enum.at(match, 6)) do
           nil ->
             nil

           mins ->
             {stime, Timex.shift(stime, minutes: mins)}
         end
       end},
      {~r/^\s*([0-9.]+)\s*([a-z]+)?$/i,
       fn match, _time ->
         case time_duration(match) do
           nil ->
             nil

           mins ->
             {Timex.shift(reference, minutes: -mins), reference}
         end
       end}
    ]

    case enum_rx(time_rxs, input) do
      nil ->
        {:error, "Sorry, I don't understand the time range #{inspect(input)}"}

      {stime, etime} ->
        {:ok, stime, etime, Timex.to_unix(etime) - Timex.to_unix(stime)}
    end
  end

  def hr_to_zulu(hr, ""), do: hr
  def hr_to_zulu(hr, "A"), do: hr

  def hr_to_zulu(hr, "P") do
    hr + 12
  end

  def time_at_today(input, reference) when is_binary(input),
    do: time_at_today(Regex.run(~r/^\s*((\d+):(\d+))\s*((p|a)m?)?$/i, input), reference)

  def time_at_today(nil, _reference), do: nil

  def time_at_today(regmatch, reference) do
    {mhr, mmin} =
      case regmatch do
        [_, _, hr, min] ->
          {str_to_int!(hr, 0), str_to_int!(min, 0)}

        [_, _, hr, min, _ampm, ap] ->
          {str_to_int!(hr, 0) |> hr_to_zulu(String.upcase(ap)), str_to_int!(min, 0)}
      end

    # this is a fail if we don't consider timezone
    # drop today's time, then add it back in
    reference
    |> Timex.to_date()
    |> Timex.to_datetime()
    |> Timex.shift(hours: mhr)
    |> Timex.shift(minutes: mmin)

    #    now_t = Timex.to_unix(reference)
    #    midnight_t = now_t - rem(now_t, 86400)
    #    adjusted_t = midnight_t + mhr * 3600 + mmin * 60
    #    DateTime.from_unix!(adjusted_t)
  end

  def time_duration([match, match1]), do: time_duration([match, match1, ""])

  def time_duration([_match, match1, match2]) do
    to_minutes(match1, match2)
  end

  def time_duration(input) when is_binary(input) do
    time_duration(Regex.run(~r/^\s*([0-9.]+)\s*([a-z]+)?/i, input))
  end

  def time_duration(nil), do: nil

  def to_minutes(number, label) do
    {:ok, num} = str_to_float(number)

    enum_rx(
      [
        {~r/^(m|min(s)?|minute(s)?)$/, fn _, _ -> num end},
        {~r/^(h|hr(s)?|hour(s)?)$/, fn _, _ -> num * 60 end},
        {~r/^(d|day(s)?)$/, fn _, _ -> num * 60 * 24 end},
        {~r/^(s|sec(s)?|second(s)?)$/, fn _, _ -> num / 60 end},
        {~r/now/, fn _, _ -> 0 end},
        {~r//, fn _, _ -> num end}
      ],
      label
    )
    |> ifloor
  end

  @doc """
  this wraps the complexities brought on by Erlang being fancy with time,
  and gives us a conventional posix/epoch time value.  The time value to
  return is specified by the first argument, as an atom, and is a required
  argument (to remove ambiguity), from the set:

    :second, :millisecond, :microsecond or :nanosecond

  It also uses their best value for 'monotonic' time so the clock will
  not go backwards.

  For the full story see:
    https://hexdocs.pm/elixir/System.html
    http://erlang.org/doc/apps/erts/time_correction.html
  """
  @spec epoch_time(time_type :: atom) :: integer
  def epoch_time(time_type)
      when time_type in [:second, :millisecond, :microsecond, :nanosecond] do
    System.monotonic_time(time_type) + System.time_offset(time_type)
  end
end
