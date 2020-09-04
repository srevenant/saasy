defmodule Utils.Errors do
  @moduledoc """
  Helper module for working with ok/error tuples
  """

  alias Ecto.Changeset
  alias Phoenix.HTML
  require Logger

  @doc """
  Convert an error tuple with a changeset or a plain changeset to a string
  error represenation.

  ## Example

      iex> convert_error_changeset({:error, changeset})
      {:error, "'name' is required"}

      iex> convert_error_changeset(changeset)
      "'name' is required"

      iex> convert_error_changeset({:ok, "user"})
      {:ok, "user"}

  """
  @spec convert_error_changeset(result :: term | {:error, Changeset.t()} | Changeset.t()) ::
          term | {:error, String.t()} | String.t()
  def convert_error_changeset({:error, %Changeset{} = changeset}) do
    {:error, convert_error_changeset(changeset)}
  end

  def convert_error_changeset(%Changeset{} = changeset) do
    Enum.join(errors_to_list(changeset), ", ")
  end

  def convert_error_changeset(other), do: other

  @doc """
  Convert nested changeset errors to a map that can more easily be tested.
  """
  @spec changeset_errors_to_map(Changeset.t()) :: map()
  def changeset_errors_to_map(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Convert a changeset with errors to a single text message that expresses any
  errors as a list of friendlier error messages/strings.
  """
  @spec errors_to_list(Changeset.t()) :: list(String.t())
  def errors_to_list(%Changeset{} = changeset) do
    errors = changeset_errors_to_map(changeset)

    messages =
      Enum.map(errors, fn {key, errors} ->
        field_name = Atom.to_string(key)
        field_message(field_name, errors, get_user_value(changeset, key))
      end)

    List.flatten(messages)
  end

  @spec get_user_value(Changeset.t(), field :: atom()) :: term
  defp get_user_value(%{params: params} = _changeset, field) when is_atom(field) do
    # sanitize the user input to make it safe
    # if an empty string, treat as nil for friendier messages
    escaped_value = HTML.html_escape(params[Atom.to_string(field)])

    case escaped_value do
      {:safe, nil} -> nil
      {:safe, ""} -> nil
      {:safe, other} -> other
    end
  end

  @spec field_message(field_name :: String.t(), errors :: list(String.t()), value :: term) ::
          list(String.t())
  defp field_message(field_name, errors, value)
       when is_binary(field_name) and is_list(errors) and value,
       do: field_message(field_name, errors, nil)

  defp field_message(field_name, errors, _ignore)
       when is_binary(field_name) and is_list(errors) do
    Enum.map(errors, fn part -> "`#{field_name}` #{part}" end)
  end

  #  defp field_message(field_name, errors, value) when is_binary(field_name) and is_list(errors) do
  #    Enum.map(errors, fn part -> "'#{field_name}' of #{inspect(value)} #{part}" end)
  #  end

  ##############################################################################
  def log_error({:ok, _} = pass, _src), do: pass

  def log_error({:error, %Ecto.Changeset{} = chgset}, src),
    do: log_error(convert_error_changeset(chgset), src) |> IO.inspect()

  def log_error({:error, error} = pass, src) do
    Logger.warn(error, src: src)
    pass
  end
end
