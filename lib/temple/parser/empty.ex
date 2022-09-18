defmodule Temple.Parser.Empty do
  @moduledoc false
  @behaviour Temple.Ast

  defstruct []

  @impl true
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  @impl true
  def run(_ast) do
    Temple.Ast.new(__MODULE__)
  end
end
