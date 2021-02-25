defmodule Temple.Parser.Empty do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser

  @impl Parser
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  @impl Parser
  def run(_ast, buffers, _buffer) do
    buffers
  end
end
