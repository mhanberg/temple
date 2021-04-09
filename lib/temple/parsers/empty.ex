defmodule Temple.Parser.Empty do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser
  alias Temple.Ast

  @impl Parser
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  def run(_ast) do
    Ast.new(
      __MODULE__,
      meta: %{type: :empty}
    )
  end

  @impl Parser
  def run(_ast, _buffer) do
    :ok
  end

  defimpl Temple.EEx do
    def to_eex(_) do
      []
    end
  end
end
