defmodule Temple.Parser.Empty do
  @moduledoc false

  use TypedStruct

  @behaviour Temple.Parser

  typedstruct do
  end

  @impl true
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  @impl true
  def run(_ast) do
    Temple.Ast.new(__MODULE__)
  end
end
