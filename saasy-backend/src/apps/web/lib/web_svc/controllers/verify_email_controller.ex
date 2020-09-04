defmodule WebSvc.VerifyEmailController do
  @moduledoc """
  Controller that for authentication that returns validation and access tokens.
  """
  use WebSvc, :controller
  import Core.Email.Templates, only: [getcfg: 0]
  alias Core.Model.{UserCodes, UserEmails}
  require Logger

  def verify(conn, %{"code" => code}) when is_binary(code) do
    cfg = getcfg()

    validated =
      case UserCodes.one(code: code) do
        {:ok, code} ->
          case UserEmails.one(id: code.meta["email_id"]) do
            {:ok, email} ->
              UserEmails.update(email, %{verified: true})
              "?vok=" <> email.address

            _ ->
              ""
          end

        {:error, _} ->
          ""
      end

    conn
    |> redirect(external: cfg.unsubscribe <> validated)
  end

  def verify(conn, _) do
    cfg = getcfg()

    conn
    |> redirect(external: cfg.unsubscribe)
  end
end
