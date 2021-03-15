defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Buffer
  alias Temple.Parser
  alias Temple.Ast

  @impl Parser
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  def run(text) do
    Ast.new(content: text, meta: %{type: :text})
  end

  @impl Parser
  def run(text, buffer) do
    Buffer.put(buffer, text)
    Buffer.put(buffer, "\n")

    :ok
  end
end
