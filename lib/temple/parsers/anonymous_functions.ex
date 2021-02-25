defmodule Temple.Parser.AnonymousFunctions do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser
  alias Temple.Buffer

  @impl Parser
  def applicable?({_, _, args}) do
    import Temple.Parser.Private, only: [split_args: 1]

    args |> split_args() |> elem(1) |> Enum.any?(fn x -> match?({:fn, _, _}, x) end)
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, _, args}, buffers, buffer) do
    import Temple.Parser.Private

    {_do_and_else, args} =
      args
      |> split_args()

    {args, func_arg, args2} = split_on_fn(args, {[], nil, []})

    {func, _, [{arrow, _, [[{arg, _, _}], block]}]} = func_arg

    Buffer.put(
      buffers[buffer],
      "<%= " <>
        to_string(name) <>
        " " <>
        (Enum.map(args, &Macro.to_string(&1)) |> Enum.join(", ")) <>
        ", " <>
        to_string(func) <> " " <> to_string(arg) <> " " <> to_string(arrow) <> " %>"
    )

    Buffer.put(buffers[buffer], "\n")

    buffers = traverse(buffers, buffer, block)

    if Enum.any?(args2) do
      Buffer.put(
        buffers[buffer],
        "<% end, " <>
          (Enum.map(args2, fn arg -> Macro.to_string(arg) end)
           |> Enum.join(", ")) <> " %>"
      )

      Buffer.put(buffers[buffer], "\n")
    else
      Buffer.put(buffers[buffer], "<% end %>")
      Buffer.put(buffers[buffer], "\n")
    end

    buffers
  end
end
