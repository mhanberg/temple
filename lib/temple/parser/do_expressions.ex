defmodule Temple.Parser.DoExpressions do
  @moduledoc false
  alias Temple.Parser

  @behaviour Parser

  defstruct elixir_ast: nil, children: []

  @impl Parser
  def applicable?({_, _, args}) when is_list(args) do
    Enum.any?(args, fn arg -> match?([{:do, _} | _], arg) end)
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, meta, args}) do
    {do_and_else, args} = Temple.Parser.Utils.split_args(args)

    do_body = Temple.Parser.parse(do_and_else[:do])

    else_body =
      if do_and_else[:else] == nil do
        nil
      else
        Temple.Parser.parse(do_and_else[:else])
      end

    Temple.Ast.new(__MODULE__, elixir_ast: {name, meta, args}, children: [do_body, else_body])
  end

  defimpl Temple.Generator do
    def to_eex(%{elixir_ast: expression, children: [do_body, else_body]}, indent \\ 0) do
      [
        "#{Parser.Utils.indent(indent)}<%= ",
        Macro.to_string(expression),
        " do %>",
        "\n",
        for(child <- do_body, do: Temple.Generator.to_eex(child, indent + 1))
        |> Enum.intersperse("\n"),
        if(else_body != nil,
          do: [
            "#{Parser.Utils.indent(indent)}\n<% else %>\n",
            for(child <- else_body, do: Temple.Generator.to_eex(child, indent + 1))
            |> Enum.intersperse("\n")
          ],
          else: ""
        ),
        "\n#{Parser.Utils.indent(indent)}<% end %>"
      ]
    end
  end
end
