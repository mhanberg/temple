defmodule Temple.Parser.RightArrow do
  @moduledoc false
  alias Temple.Parser

  @behaviour Parser

  defstruct elixir_ast: nil, children: []

  @impl Parser
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  @impl Parser
  def run({func, meta, [pattern, args]}) do
    children = Parser.parse(args)

    Temple.Ast.new(__MODULE__, elixir_ast: {func, meta, [pattern]}, children: children)
  end
end
