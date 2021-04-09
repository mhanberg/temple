defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Buffer
  alias Temple.Parser
  alias Temple.Ast

  @impl Parser
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  def run(text) do
    Ast.new(
      __MODULE__,
      content: text,
      meta: %{type: :text}
    )
  end

  @impl Parser
  def run(text, buffer) do
    Buffer.put(buffer, text)
    Buffer.put(buffer, "\n")

    :ok
  end

  defimpl Temple.EEx do
    def to_eex(%{content: text}) do
      [text]
    end
  end
end
