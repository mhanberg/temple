defmodule Temple.LiveViewEngine do
  @behaviour Phoenix.Template.Engine

  @moduledoc """
  The Temple LiveView engine makes it possible to use Temple with Phoenix LiveView.

  To get started, you will configure Phoenix to use this module for `.lexs` files.

  ```elixir
  # config.exs
  config :phoenix, :template_engines,
    # this will work for files named like `index.html.lexs`
    # you can enable Elixir syntax highlighting in your editor for this extension
    lexs: Temple.LiveViewEngine

  # config/dev.exs
  config :your_app, YourAppWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r"lib/myapp_web/(live|views)/.*(ex|exs|lexs)$",
        ~r"lib/myapp_web/templates/.*(eex|exs|lexs)$"
      ]
    ]

  # my_app/
  #   lib/
  #     my_app/
  #     my_app_web/
  #       live/
  #         posts_live/
  #           show.ex
  #           show.html.lexs
  ```

  Now you can get started by writing `lexs` files co-located with your live views and they will be compiled as you would expect.
  """

  def compile(path, _name) do
    require Temple

    template = path |> File.read!() |> Code.string_to_quoted!(file: path)

    Temple.temple(template)
    |> EEx.compile_string(engine: Phoenix.LiveView.Engine, file: path, line: 1)
  end
end
