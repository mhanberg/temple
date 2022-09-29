defmodule Temple.Ast.DoExpressions do
  @moduledoc false
  @behaviour Temple.Parser

  use TypedStruct

  typedstruct do
    field :elixir_ast, Macro.t()
    field :children, [map()]
  end

  @impl true
  def applicable?({_, _, args}) when is_list(args) do
    Enum.any?(args, fn arg -> match?([{:do, _} | _], arg) end)
  end

  def applicable?(_), do: false

  @impl true
  def run({name, meta, args}) do
    {do_and_else, args} = Temple.Ast.Utils.split_args(args)

    do_body = Temple.Parser.parse(do_and_else[:do])

    else_body =
      if do_and_else[:else] == nil do
        nil
      else
        Temple.Parser.parse(do_and_else[:else])
      end

    Temple.Ast.new(__MODULE__, elixir_ast: {name, meta, args}, children: [do_body, else_body])
  end
end
