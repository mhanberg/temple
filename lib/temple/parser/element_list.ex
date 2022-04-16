defmodule Temple.Parser.ElementList do
  @moduledoc false

  @behaviour Temple.Parser

  defstruct children: [], whitespace: :loose

  @impl Temple.Parser
  def applicable?(asts), do: is_list(asts)

  @impl Temple.Parser
  def run(asts) do
    children = Enum.flat_map(asts, &Temple.Parser.parse/1)

    Temple.Ast.new(__MODULE__, children: children)
  end
end
