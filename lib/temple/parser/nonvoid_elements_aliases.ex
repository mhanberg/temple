defmodule Temple.Parser.NonvoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct name: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?({name, _, _}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, _, args}) do
    name = Parser.nonvoid_elements_lookup()[name]

    {do_and_else, args} =
      args
      |> Temple.Parser.Utils.split_args()

    {do_and_else, args} = Temple.Parser.Utils.consolidate_blocks(do_and_else, args)

    children = Temple.Parser.parse(do_and_else[:do])

    Temple.Ast.new(__MODULE__, name: to_string(name), attrs: args, children: children)
  end

  defimpl Temple.Generator do
    def to_eex(%{name: name, attrs: attrs, children: children}) do
      [
        "<",
        name,
        Temple.Parser.Utils.compile_attrs(attrs),
        ">\n",
        for(child <- children, do: Temple.Generator.to_eex(child)),
        "\n</",
        name,
        ">"
      ]
    end
  end
end
