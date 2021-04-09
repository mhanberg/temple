defmodule Temple.Parser.VoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

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
        Temple.Parser.Private.compile_attrs(attrs),
        ">\n"
      ]
    end
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
