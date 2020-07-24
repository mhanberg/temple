# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :temple_demo,
  ecto_repos: [TempleDemo.Repo]

config :phoenix, :template_engines, exs: Temple.Engine

# Configures the endpoint
config :temple_demo, TempleDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ww1nKdikInNFHHUfSdCE1wiTcOmQq/KLvOxG7CY1TlKLDTmLW5yheCCYpfoxmZAW",
  render_errors: [view: TempleDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TempleDemo.PubSub,
  live_view: [signing_salt: "KCU/YIG0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :temple,
  aliases: [
    label: :_label,
    link: :_link,
    textarea: :_textarea
  ],
  component_prefix: TempleDemoWeb.Component

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
