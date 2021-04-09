defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser
  alias Temple.Ast

  @impl Parser
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  @impl Parser
  def run(text) do
    Ast.new(
      __MODULE__,
      content: text
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: text}) do
      [text, "\n"]
    end
  end
end
