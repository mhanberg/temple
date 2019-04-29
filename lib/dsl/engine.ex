defmodule Dsl.Engine do
  @behaviour Phoenix.Template.Engine

  def compile(path, _name) do
    template =
      path
      |> File.read!()
      |> Code.string_to_quoted!(file: path)
      |> handle_assigns()

    quote do
      use Dsl

      htm(do: unquote(template))
    end
  end

  defp handle_assigns(quoted) do
    quoted
    |> Macro.prewalk(fn
      {:@, _, [{key, _, _}]} ->
        quote do
          case Access.fetch(var!(assigns), unquote(key)) do
            {:ok, val} ->
              val

            :error ->
              raise ArgumentError, """
              assign @#{unquote(key)} not available in Dsl template.
              Please make sure all proper assigns have been set. If this
              is a child template, ensure assigns are given explicitly by
              the parent template as they are not automatically forwarded.
              Available assigns: #{inspect(Enum.map(var!(assigns), &elem(&1, 0)))}
              """
          end
        end

      ast ->
        ast
    end)
  end
end
