defmodule Temple.Parser.Match do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?({name, _, _}) do
    name in [:=]
  end

  def applicable?(_), do: false

  @impl Parser
  def run(macro) do
    Temple.Ast.new(
      __MODULE__,
      meta: %{type: :match},
      content: macro
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: content}) do
      ["<% ", Macro.to_string(content), " %>"]
    end
  end
end
