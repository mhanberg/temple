defmodule Temple.Parser.NonvoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

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
      __MODULE__,
      content: to_string(name),
      meta: %{type: :nonvoid_alias},
      attrs: args,
      children: children
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: content, attrs: attrs, children: children}) do
      [
        "<",
        content,
        Temple.Parser.Utils.compile_attrs(attrs),
        ">\n",
        for(child <- children, do: Temple.EEx.to_eex(child)),
        "\n</",
        content,
        ">"
      ]
    end
  end
end
