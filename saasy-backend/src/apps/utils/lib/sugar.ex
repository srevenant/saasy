defmodule Utils.Sugar do
  ## Mostly this is for playing around with macros - BJG
  # @moduledoc """
  # These are for making simpler to read syntax.  This is largely sugar, and on
  # some level can be dangerous as it's not mainstream code.
  #
  # I've tried to keep the shortcuts similar to their functional equivalents.
  # """
  #
  # @doc """
  # enum_map [...], fn x ->
  #   ...
  # end
  #
  # vs
  #
  # Enum.map([...], fn x ->
  #   ...
  # end)
  # """
  # defmacro enum_map(list, func) do
  #   quote do
  #     Enum.map(unquote(list), unquote(func))
  #   end
  # end
  #
  # defmacro enum_reduce(list, func) do
  #   quote do
  #     Enum.reduce(unquote(list), unquote(func))
  #   end
  # end
  #
  # defmacro enum_filter(list, func) do
  #   quote do
  #     Enum.filter(unquote(list), unquote(func))
  #   end
  # end
end
