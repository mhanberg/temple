defmodule Temple.Parser.VoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?({name, _, _}) do
    name in Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, _, args}) do
    {_do_and_else, [args]} = Temple.Parser.Utils.split_args(args)

    name = Parser.void_elements_lookup()[name]

    Temple.Ast.new(
      __MODULE__,
      content: name,
      meta: %{type: :void_alias},
      attrs: args
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: content, attrs: attrs}) do
      [
        "<",
        to_string(content),
        Temple.Parser.Utils.compile_attrs(attrs),
        ">\n"
      ]
    end
  end
end
