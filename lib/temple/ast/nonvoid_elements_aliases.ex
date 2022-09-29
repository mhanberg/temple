defmodule Temple.Ast.NonvoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  use TypedStruct

  typedstruct do
    field :name, atom()
    field :attrs, list()
    field :children, list()
    field :meta, map()
  end

  alias Temple.Parser

  @impl true
  def applicable?({name, _, _}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  @impl true
  def run({name, meta, args}) do
    name = Parser.nonvoid_elements_lookup()[name]

    {do_and_else, args} = Temple.Ast.Utils.split_args(args)

    {do_and_else, args} = Temple.Ast.Utils.consolidate_blocks(do_and_else, args)

    children = Temple.Parser.parse(do_and_else[:do])

    Temple.Ast.new(__MODULE__,
      name: to_string(name) |> String.replace_suffix("!", ""),
      attrs: args,
      meta: %{whitespace: whitespace(meta)},
      children:
        Temple.Ast.new(Temple.Ast.ElementList,
          children: children,
          whitespace: whitespace(meta)
        )
    )
  end

  defp whitespace(meta) do
    if Keyword.has_key?(meta, :end) do
      :loose
    else
      :tight
    end
  end
end
