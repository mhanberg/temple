defmodule Temple.Parser.Default do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?(_ast), do: true

  @impl Parser
  def run(ast) do
    Temple.Ast.new(
      __MODULE__,
      content: ast
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: expression}) do
      ["<%= ", Macro.to_string(expression), " %>\n"]
    end
  end
end
