defmodule Temple.Parser.VoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({name, _, _}) do
    name in Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  def run({name, _, args}) do
    {_do_and_else, [args]} = Temple.Parser.Private.split_args(args)

    name = Parser.void_elements_lookup()[name]

    Temple.Ast.new(
      content: name,
      meta: %{type: :void_alias},
      attrs: args
    )
  end

  @impl Parser
  def run({name, _, args}, buffer) do
    import Temple.Parser.Private

    {_do_and_else, args} =
      args
      |> split_args()

    name = Parser.void_elements_lookup()[name]

    Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
    Buffer.put(buffer, "\n")

    :ok
  end
end
