defmodule Temple.Parser.Match do
  @moduledoc false
  @behaviour Temple.Ast

  defstruct elixir_ast: nil

  alias Temple.Parser

  @impl true
  def applicable?({name, _, _}) do
    name in [:=]
  end

  def applicable?(_), do: false

  @impl true
  def run(macro) do
    Temple.Ast.new(__MODULE__, elixir_ast: macro)
  end
end
