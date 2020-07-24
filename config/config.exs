use Mix.Config

config :temple, :component_prefix, Temple.Components
import_config "#{Mix.env()}.exs"
