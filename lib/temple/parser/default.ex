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
end
