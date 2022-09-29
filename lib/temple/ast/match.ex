defmodule Temple.Ast.Match do
  @moduledoc false
  @behaviour Temple.Parser

  use TypedStruct

  typedstruct do
    field :elixir_ast, Macro.t()
  end

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
