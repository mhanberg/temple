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

  @impl Parser
  def run({name, _, args}, buffers, buffer) do
    import Temple.Parser.Private

    {_do_and_else, args} =
      args
      |> split_args()

    name = Parser.void_elements_lookup()[name]

    Buffer.put(buffers[buffer], "<#{name}#{compile_attrs(args)}>")
    Buffer.put(buffers[buffer], "\n")

    buffers
  end
end
