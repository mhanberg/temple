defmodule Temple.Parser.RightArrow do
  @moduledoc false

  @behaviour Temple.Ast

  defstruct elixir_ast: nil, children: []

  @impl true
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  @impl true
  def run({func, meta, [pattern, args]}) do
    children = Temple.Parser.parse(args)

    Temple.Ast.new(__MODULE__, elixir_ast: {func, meta, [pattern]}, children: children)
  end
end
