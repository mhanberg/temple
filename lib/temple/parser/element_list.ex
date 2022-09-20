defmodule Temple.Parser.ElementList do
  @moduledoc false

  @behaviour Temple.Parser

  use TypedStruct

  typedstruct do
    field :children, list()
    field :whitespace, :loose | :tight
  end

  @impl true
  def applicable?(asts), do: is_list(asts)

  @impl true
  def run(asts) do
    children = Enum.flat_map(asts, &Temple.Parser.parse/1)

    Temple.Ast.new(__MODULE__, children: children)
  end
end
