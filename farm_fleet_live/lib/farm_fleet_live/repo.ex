defmodule FarmFleetLive.Repo do
  use Ecto.Repo,
    otp_app: :farm_fleet_live,
    adapter: Ecto.Adapters.Postgres
end
