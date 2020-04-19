defmodule Temple.Renderer do
  @moduledoc false

  defmacro __before_compile__(env) do
    render? = Module.defines?(env.module, {:render, 1})
    template = template_path(env)

    case {render?, File.regular?(template)} do
      {true, true} ->
        IO.warn(
          "ignoring template #{inspect(template)} because the LiveView " <>
            "#{inspect(env.module)} defines a render/1 function",
          Macro.Env.stacktrace(env)
        )

        :ok

      {false, true} ->
        ast = Temple.LiveViewEngine.compile(template, template_filename(env))

        quote do
          @file unquote(template)
          @external_resource unquote(template)
          def render(var!(assigns)) do
            unquote(ast)
          end
        end

      {_, _} ->
        :ok
    end
  end

  defp template_path(env) do
    env.file
    |> Path.dirname()
    |> Path.join(template_filename(env) <> ".exs")
    |> Path.relative_to_cwd()
  end

  def template_filename(env) do
    env.module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> Kernel.<>(".html")
  end
end
