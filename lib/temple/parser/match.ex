defmodule Temple.Parser.Match do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct elixir_ast: nil

  alias Temple.Parser

  @impl Parser
  def applicable?({name, _, _}) do
    name in [:=]
  end

  def applicable?(_), do: false

  @impl Parser
  def run(macro) do
    Temple.Ast.new(__MODULE__, elixir_ast: macro)
  end
end
