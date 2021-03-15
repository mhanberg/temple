defmodule Temple.Parser.TempleNamespaceNonvoid do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({{:., _, [{:__aliases__, _, [:Temple]}, name]}, _meta, _args}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  def run({name, _, args}) do
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name
    name = Parser.nonvoid_elements_lookup()[name]

    {do_and_else, args} =
      args
      |> Temple.Parser.Private.split_args()

    {do_and_else, args} =
      case args do
        [args] when is_list(args) ->
          {do_value, args} = Keyword.pop(args, :do)

          do_and_else = Keyword.put_new(do_and_else, :do, do_value)

          {do_and_else, args}

        _ ->
          {do_and_else, args}
      end

    children = Temple.Parser.parse(do_and_else[:do])

    Temple.Ast.new(
      content: to_string(name),
      meta: %{type: :temple_nonvoid},
      attrs: args,
      children: children
    )
  end

  @impl Parser
  def run({name, _, args}, buffer) do
    import Temple.Parser.Private
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

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

    Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
    unless compact?, do: Buffer.put(buffer, "\n")
    traverse(buffer, do_and_else[:do])
    if compact?, do: Buffer.remove_new_line(buffer)
    Buffer.put(buffer, "</#{name}>")
    Buffer.put(buffer, "\n")

    :ok
  end
end
