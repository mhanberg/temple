defmodule TemplePlugDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true

  def start(_type, _args) do
    children =
      [
        {Bandit, plug: TemplePlugDemo.Router, scheme: :http, options: [port: 4001]}
      ] ++ watcher_children()

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def watcher_children() do
    for args <- Application.get_env(:temple_plug_demo, :watchers, []) do
      {TemplePlugDemo.Watcher, args}
    end
  end
end
