defmodule Temple.Parser.Empty do
  @behaviour Temple.Parser

  alias Temple.Parser

  @impl Parser
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  @impl Parser
  def run(_ast, _buffer) do
    :ok
  end
end
