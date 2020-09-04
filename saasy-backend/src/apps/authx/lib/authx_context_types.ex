defmodule AuthX.ContextTypes do
  @moduledoc """
  Typespec Types
  """
  use Core.ContextClient

  defmacro __using__(_) do
    quote do
      @type str :: String.t()
      @type log_msg :: str
      @type usr_msg :: str
      @type auth_result :: {:ok | :error, AuthDomain.t()}
    end
  end
end
