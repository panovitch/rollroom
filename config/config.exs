# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :roll_room,
  ecto_repos: [RollRoom.Repo]

# Configures the endpoint
config :roll_room, RollRoomWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0j/5Fl6OfYDT6MDhndCe15k8hA1FvWIPcPgPc9gle64Q6ixpVJ3YFAMZc83hxWS+",
  render_errors: [view: RollRoomWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RollRoom.PubSub,
  live_view: [signing_salt: "ILVwRaFn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
