defmodule Temple.Parser.DoExpressions do
  @moduledoc false
  alias Temple.Parser

  @behaviour Parser

  defstruct content: nil, attrs: [], children: []

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

    Temple.Ast.new(
      __MODULE__,
      children: [do_body, else_body],
      content: {name, meta, args}
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: expression, children: [do_body, else_body]}) do
      [
        "<%= ",
        Macro.to_string(expression),
        " do %>",
        "\n",
        for(child <- do_body, do: Temple.EEx.to_eex(child)),
        if(else_body != nil,
          do: ["<% else %>\n", for(child <- else_body, do: Temple.EEx.to_eex(child))],
          else: ""
        ),
        "<% end %>"
      ]
    end
  end
end
