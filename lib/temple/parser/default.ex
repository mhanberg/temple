defmodule Temple.Parser.Default do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct elixir_ast: nil

  alias Temple.Parser

  @impl Parser
  def applicable?(_ast), do: true

  @impl Parser
  def run(ast) do
    Temple.Ast.new(__MODULE__, elixir_ast: ast)
  end

  defimpl Temple.Generator do
    def to_eex(%{elixir_ast: expression}) do
      ["<%= ", Macro.to_string(expression), " %>\n"]
    end
  end
end
