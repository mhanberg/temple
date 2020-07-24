defmodule Temple.Parser.Text do
  @behaviour Temple.Parser

  alias Temple.Buffer
  alias Temple.Parser

  @impl Parser
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  @impl Parser
  def run(text, buffer) do
    Buffer.put(buffer, text)
    Buffer.put(buffer, "\n")

    :ok
  end
end
