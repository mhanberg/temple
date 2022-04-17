import Config

config :tailwind,
  version: "3.0.24",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :temple_plug_demo, :watchers,
  tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
