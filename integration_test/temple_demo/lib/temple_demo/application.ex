defmodule TempleDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      TempleDemo.Repo,
      # Start the Telemetry supervisor
      # Start the PubSub system
      {Phoenix.PubSub, name: TempleDemo.PubSub},
      # Start the Endpoint (http/https)
      TempleDemoWeb.Endpoint
      # Start a worker by calling: TempleDemo.Worker.start_link(arg)
      # {TempleDemo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TempleDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TempleDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
