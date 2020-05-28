use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :temple_demo, TempleDemo.Repo,
  username: "postgres",
  password: "postgres",
  database: "temple_demo_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :temple_demo, TempleDemoWeb.Endpoint,
  http: [port: 4002],
  server: true

config :temple_demo, :sql_sandbox, true

config :wallaby,
  otp_app: :temple_demo,
  driver: Wallaby.Experimental.Chrome,
  screenshot_on_failure: true


# Print only warnings and errors during test
config :logger, level: :warn
