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
  def run({name, meta, args}, buffers, buffer) do
    import Temple.Parser.Private

    {do_and_else, args} =
      args
      |> split_args()

    Buffer.put(buffers[buffer], "<%= " <> Macro.to_string({name, meta, args}) <> " do %>")
    Buffer.put(buffers[buffer], "\n")

    buffers = traverse(buffers, buffer, do_and_else[:do])

    buffers =
      if Keyword.has_key?(do_and_else, :else) do
        Buffer.put(buffers[buffer], "<% else %>")
        Buffer.put(buffers[buffer], "\n")
        traverse(buffers, buffer, do_and_else[:else])
      else
        buffers
      end

    Buffer.put(buffers[buffer], "<% end %>")
    Buffer.put(buffers[buffer], "\n")

    buffers
  end
end
