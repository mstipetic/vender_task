defmodule Vending.Repo do
  use Ecto.Repo,
    otp_app: :vending,
    adapter: Ecto.Adapters.Postgres
end
