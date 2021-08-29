defmodule Temple.Parser.NonvoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct name: nil, attrs: [], children: [], meta: %{}

  alias Temple.Parser

  @impl Parser
  def applicable?({name, _, _}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, _, args}) do
    name = Parser.nonvoid_elements_lookup()[name]

    {do_and_else, args} = Temple.Parser.Utils.split_args(args)

    {do_and_else, args} = Temple.Parser.Utils.consolidate_blocks(do_and_else, args)

    children = Temple.Parser.parse(do_and_else[:do])

    Temple.Ast.new(__MODULE__,
      name: to_string(name) |> String.replace_suffix("!", ""),
      attrs: args,
      children:
        Temple.Ast.new(Temple.Parser.ElementList,
          children: children,
          whitespace: whitespace(to_string(name))
        )
    )
  end

  defp whitespace(name) do
    if String.ends_with?(name, "!") do
      :tight
    else
      :loose
    end
  end

  defimpl Temple.Generator do
    def to_eex(%{name: name, attrs: attrs, children: children}, indent \\ 0) do
      [
        "#{Parser.Utils.indent(indent)}<",
        name,
        Temple.Parser.Utils.compile_attrs(attrs),
        ">",
        Temple.Generator.to_eex(children, indent),
        "</",
        name,
        ">"
      ]
    end
  end
end
