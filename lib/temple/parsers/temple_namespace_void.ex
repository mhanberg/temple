defmodule Temple.Parser.TempleNamespaceVoid do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({{:., _, [{:__aliases__, _, [:Temple]}, name]}, _meta, _args}) do
    name in Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  def run({name, _, [args]}) do
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

    name = Parser.void_elements_lookup()[name]

    Temple.Ast.new(
      content: to_string(name),
      meta: %{type: :temple_void},
      attrs: args
    )
  end

  @impl Parser
  def run({name, _, args}, buffer) do
    import Temple.Parser.Private
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

    {_do_and_else, args} =
      args
      |> split_args()

    name = Parser.void_elements_lookup()[name]

    Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
    Buffer.put(buffer, "\n")

    :ok
  end
end
