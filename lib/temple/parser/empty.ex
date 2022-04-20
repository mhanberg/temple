defmodule Temple.Parser.Empty do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct []

  alias Temple.Parser

  @impl Parser
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  @impl Parser
  def run(_ast) do
    Temple.Ast.new(__MODULE__)
  end
end
