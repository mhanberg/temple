defmodule Mix.Tasks.Dsl.Gen.Layout do
  use Mix.Task

  @shortdoc "Generates a default Phoenix layout file in Dsl"

  @moduledoc """
  Generates a Phoenix layout file in Dsl.
      mix dsl.gen.layout
  """
  def run(_args) do
    context_app = Mix.Phoenix.context_app()
    web_prefix = Mix.Phoenix.web_path(context_app)
    binding = [application_module: Mix.Phoenix.base()]

    Mix.Phoenix.copy_from(dsl_paths(), "priv/templates/dsl.gen.layout", binding, [
      {:eex, "app.html.eex", "#{web_prefix}/templates/layout/app.html.exs"}
    ])

    instructions = """
    A new #{web_prefix}/templates/layout/app.html.exs file was generated.
    """

    Mix.shell().info(instructions)
  end

  defp dsl_paths do
    [".", :dsl]
  end
end
