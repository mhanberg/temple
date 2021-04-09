defmodule Temple.Parser.Empty do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?(ast) when ast in [nil, []], do: true
  def applicable?(_), do: false

  @impl Parser
  def run(_ast) do
    Temple.Ast.new(
      __MODULE__,
      meta: %{type: :empty}
    )
  end

  defimpl Temple.EEx do
    def to_eex(_) do
      []
    end
  end
end
