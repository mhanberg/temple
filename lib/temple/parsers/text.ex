defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Buffer
  alias Temple.Parser

  @impl Parser
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  @impl Parser
  def run(text, buffers, buffer) do
    Buffer.put(buffers[buffer], text)
    Buffer.put(buffers[buffer], "\n")

    buffers
  end
end
