defmodule Core.Email.BambooMailer do
  require Logger
  use Bamboo.Mailer, otp_app: :core
end
