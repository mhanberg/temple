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

  defimpl Temple.Generator do
    def to_eex(%{elixir_ast: elixir_ast}, indent \\ 0) do
      ["#{Parser.Utils.indent(indent)}<% ", Macro.to_string(elixir_ast), " %>"]
    end
  end
end
