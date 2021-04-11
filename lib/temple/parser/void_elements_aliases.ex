defmodule Temple.Parser.VoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct name: nil, attrs: []

  @impl Temple.Parser
  def applicable?({name, _, _}) do
    name in Temple.Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Temple.Parser
  def run({name, _, args}) do
    {_do_and_else, [args]} = Temple.Parser.Utils.split_args(args)

    name = Temple.Parser.void_elements_lookup()[name]

    Temple.Ast.new(__MODULE__, name: name, attrs: args)
  end

  defimpl Temple.Generator do
    def to_eex(%{name: name, attrs: attrs}) do
      [
        "<",
        to_string(name),
        Temple.Parser.Utils.compile_attrs(attrs),
        ">\n"
      ]
    end
  end
end
