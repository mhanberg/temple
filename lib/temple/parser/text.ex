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
end
