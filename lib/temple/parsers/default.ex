defmodule Temple.Parser.Default do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?(_ast), do: true

  def run(ast) do
    Temple.Ast.new(
      meta: %{type: :default},
      content: ast
    )
  end

  @impl Parser
  def run({_, _, args} = macro, buffer) do
    import Temple.Parser.Private

    {do_and_else, _args} =
      args
      |> split_args()

    Buffer.put(buffer, "<%= " <> Macro.to_string(macro) <> " %>")
    Buffer.put(buffer, "\n")
    traverse(buffer, do_and_else[:do])

    :ok
  end
end
