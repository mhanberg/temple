defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct text: nil

  alias Temple.Parser

  @impl Parser
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  @impl Parser
  def run(text) do
    Temple.Ast.new(__MODULE__, text: text)
  end

  defimpl Temple.Generator do
    def to_eex(%{text: text}, indent \\ 0) do
      [Parser.Utils.indent(indent), text]
    end
  end
end
