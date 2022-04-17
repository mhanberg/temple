defmodule Temple.Engine do
  @behaviour Phoenix.Template.Engine

  @moduledoc """
  The Temple HTML engine makes it possible to use Temple with Phoenix controllers.

  To get started, you will configure Phoenix to use this module for `.exs` files.

  ```elixir
  # config.exs
  config :phoenix, :template_engines,
    # this will work for files named like `index.html.exs`
    exs: Temple.Engine

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
  #       templates/
  #         posts/
  #           show.html.exs
  ```

  Now you can get started by writing `exs` files in the templates directory and they will be compiled as you would expect.
  """

  def compile(path, _name) do
    require Temple.Renderer

    template = path |> File.read!() |> Code.string_to_quoted!(file: path)

    template
    |> Temple.Parser.parse()
    |> Temple.Renderer.render(engine: Temple.engine())

    # |> Temple.Parser.Utils.inspect_ast()
  end
end
