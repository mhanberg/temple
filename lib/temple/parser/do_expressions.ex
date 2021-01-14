defmodule Temple.Parser.DoExpressions do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({_, _, args}) when is_list(args) do
    Enum.any?(args, fn arg -> match?([{:do, _} | _], arg) end)
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, meta, args}, buffer) do
    import Temple.Parser.Utils

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
