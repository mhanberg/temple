defmodule Temple.Parser.Empty do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Ast

  @impl Parser
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  def run(_ast) do
    Ast.new(meta: %{type: :empty})
  end

  @impl Parser
  def run(_ast, _buffer) do
    :ok
  end
end
