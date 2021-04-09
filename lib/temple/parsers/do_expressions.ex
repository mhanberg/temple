defmodule Temple.Parser.DoExpressions do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({_, _, args}) when is_list(args) do
    Enum.any?(args, fn arg -> match?([{:do, _} | _], arg) end)
  end

  def applicable?(_), do: false

  def run({name, meta, args}) do
    {do_and_else, args} = Temple.Parser.Private.split_args(args)

    do_body = Temple.Parser.parse(do_and_else[:do])

    else_body =
      if do_and_else[:else] == nil do
        nil
      else
        Temple.Parser.parse(do_and_else[:else])
      end

    Temple.Ast.new(
      __MODULE__,
      meta: %{type: :do_expression},
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
          do: ["\n<% else %>\n", for(child <- else_body, do: Temple.EEx.to_eex(child))],
          else: ""
        ),
        "\n",
        "<% end %>"
      ]
    end
  end

  @impl Parser
  def run({name, meta, args}, buffer) do
    import Temple.Parser.Private

    {do_and_else, args} =
      args
      |> split_args()

    Buffer.put(buffer, "<%= " <> Macro.to_string({name, meta, args}) <> " do %>")
    Buffer.put(buffer, "\n")

    traverse(buffer, do_and_else[:do])

    if Keyword.has_key?(do_and_else, :else) do
      Buffer.put(buffer, "<% else %>")
      Buffer.put(buffer, "\n")
      traverse(buffer, do_and_else[:else])
    end

    Buffer.put(buffer, "<% end %>")
    Buffer.put(buffer, "\n")

    :ok
  end
end
