defmodule TempleDemo.Repo do
  use Ecto.Repo,
    otp_app: :temple_demo,
    adapter: Ecto.Adapters.Postgres
end
