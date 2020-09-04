defmodule Core.ContextTypes do
  @moduledoc """
  Makes using Core contexts easy. Aliases the majority of things needed.
  """

  defmacro __using__(_) do
    quote do
      # I dislike the more lengthy String.t(), and 'string' is something else
      @type str :: String.t()
    end
  end
end
