defmodule Temple.Parser.RightArrow do
  @moduledoc false
  alias Temple.Parser

  @behaviour Parser

  defstruct elixir_ast: nil, children: []

  @impl Parser
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  @impl Parser
  def run({_, _, [[pattern], args]}) do
    children = Parser.parse(args)

    Temple.Ast.new(__MODULE__, elixir_ast: pattern, children: children)
  end

  defimpl Temple.Generator do
    def to_eex(%{elixir_ast: elixir_ast, children: children}) do
      [
        "<% ",
        Macro.to_string(elixir_ast),
        " -> %>\n",
        for(child <- children, do: Temple.Generator.to_eex(child))
      ]
    end
  end
end
