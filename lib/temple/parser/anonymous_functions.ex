defmodule Temple.Parser.AnonymousFunctions do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct elixir_ast: nil, children: []

  alias Temple.Parser

  @impl Parser
  def applicable?({_, _, args}) do
    import Temple.Parser.Utils, only: [split_args: 1]

    args
    |> split_args()
    |> elem(1)
    |> Enum.any?(fn x -> match?({:fn, _, _}, x) end)
  end

  def applicable?(_), do: false

  @impl Parser
  def run({_name, _, args} = expression) do
    {_do_and_else, args} = Temple.Parser.Utils.split_args(args)

    {_args, func_arg, _args2} = Temple.Parser.Utils.split_on_fn(args, {[], nil, []})

    {_func, _, [{_arrow, _, [[{_arg, _, _}], block]}]} = func_arg

    children = Temple.Parser.parse(block)

    Temple.Ast.new(__MODULE__, elixir_ast: expression, children: children)
  end
end
