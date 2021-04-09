defmodule Temple.Parser.RightArrow do
  @moduledoc false
  alias Temple.Parser

  @behaviour Parser

  defstruct content: nil, attrs: [], children: []

  @impl Parser
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  @impl Parser
  def run({_, _, [[pattern], args]}) do
    children = Parser.parse(args)

    Temple.Ast.new(
      __MODULE__,
      meta: %{type: :right_arrow},
      content: pattern,
      children: children
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: content, children: children}) do
      [
        "<% ",
        Macro.to_string(content),
        " -> %>\n",
        for(child <- children, do: Temple.EEx.to_eex(child))
      ]
    end
  end
end
