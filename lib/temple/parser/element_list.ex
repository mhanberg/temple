defmodule Temple.Parser.ElementList do
  @moduledoc false

  @behaviour Temple.Parser

  defstruct children: [], whitespace: :loose

  @impl Temple.Parser
  def applicable?(asts), do: is_list(asts)

  @impl Temple.Parser
  def run(asts) do
    children = Enum.flat_map(asts, &Temple.Parser.parse/1)

    Temple.Ast.new(__MODULE__, children: children)
  end

  defimpl Temple.Generator do
    def to_eex(%{children: children, whitespace: whitespace}, indent \\ 0) do
      child_indent = if whitespace == :loose, do: indent + 1, else: 0
      self_indent = if whitespace == :loose, do: indent, else: 0
      whitespace = if whitespace == :tight, do: [], else: ["\n"]

      [
        whitespace,
        for(child <- children, do: Temple.Generator.to_eex(child, child_indent))
        |> Enum.intersperse("\n"),
        whitespace,
        Temple.Parser.Utils.indent(self_indent)
      ]
    end
  end
end
