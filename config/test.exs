use Mix.Config

# this is to make the warning go away,
# Temple does not use a json_library
config :phoenix, json_library: Temple

config :temple,
  aliases: [
    select: :select__,
    link: :link__
  ]
