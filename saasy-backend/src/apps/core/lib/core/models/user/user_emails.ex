defmodule Core.Model.UserEmails do
  use Core.Context
  use Core.Model.CollectionUuid, model: Core.Model.UserEmail

  ##############################################################################
  @doc """
  Helper function which accepts either user_id or user, and calls the passed
  function with the user model loaded including any preloads.  Send preloads
  as [] if none are desired.
  """
  def with_email(%UserEmail{} = email, preloads, func) do
    case UserEmails.preload(email, preloads) do
      {:error, _} = pass ->
        pass

      {:ok, %UserEmail{} = email} ->
        func.(email)
    end
  end

  def with_email(email, preloads, func) when is_binary(email) do
    case UserEmails.one(email, preloads) do
      {:error, _} = pass ->
        pass

      {:ok, %UserEmail{} = email} ->
        func.(email)
    end
  end
end
