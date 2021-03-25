defmodule Temple.Parser.RightArrow do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({:->, _, _}), do: true
  def applicable?(_), do: false

  def run({_, _, [[pattern], args]}) do
    children = Temple.Parser.parse(args)

    Temple.Ast.new(
      meta: %{type: :right_arrow},
      content: pattern,
      children: children
    )
  end

  @impl Parser
  def run({_, _, [[pattern], args]}, buffer) do
    import Temple.Parser.Private

    Buffer.put(buffer, "<% " <> Macro.to_string(pattern) <> " -> %>\n")
    traverse(buffer, args)

    :ok
  end
end
