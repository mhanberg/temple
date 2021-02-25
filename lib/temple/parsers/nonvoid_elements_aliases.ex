defmodule Temple.Parser.NonvoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({name, _, _}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, _, args}, buffers, buffer) do
    import Temple.Parser.Private

    {do_and_else, args} =
      args
      |> split_args()

    {do_and_else, args} =
      case args do
        [args] when is_list(args) ->
          {do_value, args} = Keyword.pop(args, :do)

          do_and_else = Keyword.put_new(do_and_else, :do, do_value)

          {do_and_else, args}

        _ ->
          {do_and_else, args}
      end

    name = Parser.nonvoid_elements_lookup()[name]

    {compact?, args} = pop_compact?(args)

    Buffer.put(buffers[buffer], "<#{name}#{compile_attrs(args)}>")
    unless compact?, do: Buffer.put(buffers[buffer], "\n")
    buffers = traverse(buffers, buffer, do_and_else[:do])
    if compact?, do: Buffer.remove_new_line(buffers[buffer])
    Buffer.put(buffers[buffer], "</#{name}>")
    Buffer.put(buffers[buffer], "\n")

    buffers
  end
end
