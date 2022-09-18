defmodule Temple.Parser.Default do
  @moduledoc false
  @behaviour Temple.Ast

  defstruct elixir_ast: nil

  @impl true
  def applicable?(_ast), do: true

  @impl true
  def run(ast) do
    Temple.Ast.new(__MODULE__, elixir_ast: ast)
  end
end
