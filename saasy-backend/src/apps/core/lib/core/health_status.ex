defmodule Core.HealthStatus do
  # TODO: get this into Core
  @moduledoc """
  Common place to track health of the overall system.
  """
  #  use Phoenix.Controller
  #  use Application

  @doc """
  Return the health-check status. This is for sharing across all projects.

  TODO: Consider a way that services could register

  ## Examples

    iex> status(%{})
    :ok
    iex> status(%{"detail" => "true"})
    {:ok, %{version: "dev"}}
  """
  @spec status(params :: map) :: :ok | {:ok, map}
  def status(%{"detail" => "true"}) do
    {:ok,
     %{
       version: Application.get_env(:web, :release_version)
     }}
  end

  def status(_params) do
    :ok
  end
end
