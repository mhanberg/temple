defmodule Temple.Parser.RightArrow do
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  @impl Parser
  def run({_, _, [[pattern], args]}, buffer) do
    import Temple.Parser.Private

    Buffer.put(buffer, "<% " <> Macro.to_string(pattern) <> " -> %>\n")
    traverse(buffer, args)

    :ok
  end
end
