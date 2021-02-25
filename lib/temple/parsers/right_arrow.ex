defmodule Temple.Parser.RightArrow do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  @impl Parser
  def run({_, _, [[pattern], args]}, buffers, buffer) do
    import Temple.Parser.Private

    Buffer.put(buffer[buffer], "<% " <> Macro.to_string(pattern) <> " -> %>\n")
    buffers = traverse(buffers, buffer, args)

    buffers
  end
end
