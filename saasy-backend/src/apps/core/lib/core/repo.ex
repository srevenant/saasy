defmodule Core.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :core,
    #    adapter: Ecto.Adapters.MySQL
    adapter: Ecto.Adapters.Postgres
end
