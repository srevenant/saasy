defmodule Utils.RandChars12 do
  use EntropyString, total: 10.0e6, risk: 1.0e12
end

defmodule Utils.RandChars48 do
  def random() do
    Enum.map(1..4, fn _x -> Utils.RandChars12.random() end) |> Enum.join()
  end
end
