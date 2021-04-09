defmodule Temple.Parser.AnonymousFunctions do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?({_, _, args}) do
    import Temple.Parser.Private, only: [split_args: 1]

    args
    |> split_args()
    |> elem(1)
    |> Enum.any?(fn x -> match?({:fn, _, _}, x) end)
  end

  def applicable?(_), do: false

  @impl Parser
  def run({_name, _, args} = expression) do
    {_do_and_else, args} = Temple.Parser.Private.split_args(args)

    {_args, func_arg, _args2} = Temple.Parser.Private.split_on_fn(args, {[], nil, []})

    {_func, _, [{_arrow, _, [[{_arg, _, _}], block]}]} = func_arg

    children = Temple.Parser.parse(block)

    Temple.Ast.new(
      __MODULE__,
      content: expression,
      children: children
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: {name, _, args}, children: children}) do
      {_do_and_else, args} = Temple.Parser.Private.split_args(args)

      {args, {func, _, [{arrow, _, [[{arg, _, _}], _block]}]}, args2} =
        Temple.Parser.Private.split_on_fn(args, {[], nil, []})

      [
        "<%= ",
        to_string(name),
        " ",
        Enum.map(args, &Macro.to_string(&1)) |> Enum.join(", "),
        ", ",
        to_string(func),
        " ",
        to_string(arg),
        " ",
        to_string(arrow),
        " %>",
        "\n",
        for(child <- children, do: Temple.EEx.to_eex(child)),
        if Enum.any?(args2) do
          [
            "<% end, ",
            Enum.map(args2, fn arg -> Macro.to_string(arg) end)
            |> Enum.join(", "),
            " %>"
          ]
        else
          ["<% end %>", "\n"]
        end
      ]
    end
  end
end
