defmodule Temple.Parser.Default do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?(_), do: true

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
