defmodule RollRoom.Repo do
  use Ecto.Repo,
    otp_app: :roll_room,
    adapter: Ecto.Adapters.Postgres
end
