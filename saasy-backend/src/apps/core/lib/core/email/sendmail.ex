defmodule Core.Email.Sendmail do
  require Logger
  alias Core.Model.{UserEmail, UserEmails, User, Users}

  @doc """
    sendmail(recip, formatter)
    sendmail(recip, formatter, args)
    sendmail(recip, opts, formatter, args)

    For each good recipient call formatter(%UserEmail{}, args),
    where email.user is preloaded on %UserEmail{}

    `recip` can be a user_id, a %User{}, a %UserEmail{}, or a list of any of these

    `opts` (optional) is a dictionary with key/values:

      send: &log_email/1   -- use the test logger rather than sender
      send: &send_email/1  -- this is the default
      fail: function(error, recip)
      verified: true -- (NOT YET) -- will be a limiter to only send to verified emails
  """
  # shortcut
  def sendmail(recip, formatter) when is_function(formatter),
    do: sendmail(recip, %{}, formatter, nil)

  def sendmail(recip, formatter, args) when is_function(formatter),
    do: sendmail(recip, %{}, formatter, args)

  def sendmail([], _, _, _), do: :ok

  def sendmail([recip | recips], opts, formatter, args) do
    sendmail(recip, opts, formatter, args)
    sendmail(recips, opts, formatter, args)
  end

  def sendmail(recip, opts, formatter, args)
      when not is_list(recip) and is_map(opts) and is_function(formatter) do
    with {:ok, %UserEmail{} = email} <- get_email(recip, opts) do
      sender = Map.get(opts, :send, &send_email/1)
      formatter.(email, args) |> sender.()
    else
      err ->
        fail = Map.get(opts, :fail)

        if is_function(fail) do
          fail.(err, recip)
        end

        with {:error, %{reason: :no_email, user: user}} <- err do
          Logger.error("Unable to load email for user, cannot send email", user: user.id)
        end
    end

    :ok
  end

  ##############################################################################
  def log_email(%Bamboo.Email{} = email) do
    IO.puts("""
    Subject: #{email.subject}
    --- html
    #{email.html_body}
    --- text
    #{email.text_body}
    """)
  end

  def send_email(%Bamboo.Email{to: addr} = email) do
    if Regex.match?(~r/@example.com$/, addr) do
      Logger.info("Not delivering email to example email #{addr}")
      log_email(email)
    else
      Core.Email.BambooMailer.deliver_later(email)
    end
  end

  ##############################################################################
  # future: opts can include verfied: true (or some way to only send to verified addresses)
  defp get_email(user_id, opts) when is_binary(user_id) do
    with {:ok, user} <- Users.one(user_id) do
      get_email(user, opts)
    end
  end

  defp get_email(%UserEmail{} = email, _opts) do
    with {:ok, email} <- UserEmails.preload(email, :user) do
      {:ok, email}
    end
  end

  defp get_email(%User{} = user, _opts) do
    with {:ok, %User{emails: emails}} <- Users.preload(user, :emails) do
      case Enum.find(emails, fn e -> e.verified end) do
        %UserEmail{} = email ->
          {:ok, %UserEmail{email | user: user}}

        _ ->
          with %UserEmail{} = email <- List.first(emails) do
            {:ok, %UserEmail{email | user: user}}
          else
            _ ->
              {:error, %{reason: :no_email, user: user}}
          end
      end
    end
  end
end
