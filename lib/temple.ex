defmodule Temple do
  @nonvoid_elements ~w[
    head title style script
    noscript template
    body section nav article aside h1 h2 h3 h4 h5 h6
    header footer address main
    p pre blockquote ol ul li dl dt dd figure figcaption div
    a em strong small s cite q dfn abbr data time code var samp kbd
    sub sup i b u mark ruby rt rp bdi bdo span
    ins del
    iframe object video audio canvas
    map 
    table caption colgroup tbody thead tfoot tr td th
    form fieldset legend label button select datalist optgroup
    option textarea output progress meter
    details summary menuitem menu
    html
  ]a
  @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

  defmacro __using__(_) do
    quote location: :keep do
      import Temple
    end
  end

  def snake_to_kebab(stringable),
    do: stringable |> to_string() |> String.replace_trailing("_", "") |> String.replace("_", "-")

  def kebab_to_snake(stringable),
    do: stringable |> to_string() |> String.replace("-", "_")

  def compile_attrs([]), do: ""

  def compile_attrs([attrs]) when is_list(attrs) do
    compile_attrs(attrs)
  end

  def compile_attrs(attrs) do
    for attr <- attrs, into: "" do
      case attr do
        {name, {_, _, _} = macro} ->
          name = snake_to_kebab(name)

          " " <> name <> "=\"<%= " <> Macro.to_string(macro) <> " %>\""

        {name, value} ->
          name = snake_to_kebab(name)

          " " <> name <> "=\"" <> to_string(value) <> "\""
      end
    end
  end

  def split_args(nil), do: {[], []}

  def split_args(args) do
    args
    |> Enum.split_with(fn
      arg when is_list(arg) ->
        Keyword.has_key?(arg, :do) || Keyword.has_key?(arg, :else)

      _ ->
        false
    end)
  end

  def traverse(buffer, {:__block__, _meta, block}) do
    traverse(buffer, block)
  end

  def traverse(buffer, {:@, _meta, [{name, _, _}]}) do
    Agent.update(buffer, fn buf -> ["<%= @#{name} %>" | buf] end)
  end

  def traverse(buffer, {name, meta, args} = macro) do
    # macro
    # |> IO.inspect(label: :macro, pretty: true, limit: :infinity, printable_limit: :infinity)

    {do_and_else, args} =
      args
      |> split_args()

    do_and_else = do_and_else |> List.flatten()

    # name
    # |> IO.inspect(label: :name, pretty: true, limit: :infinity, printable_limit: :infinity)

    # do_and_else
    # |> IO.inspect(label: :do_and_else, pretty: true, limit: :infinity, printable_limit: :infinity)

    # args
    # |> IO.inspect(label: :args, pretty: true, limit: :infinity, printable_limit: :infinity)

    case name do
      name when name in @nonvoid_elements ->
        Agent.update(buffer, fn buf -> ["<#{name}#{compile_attrs(args)}>" | buf] end)
        traverse(buffer, do_and_else[:do])
        Agent.update(buffer, fn buf -> ["</#{name}>" | buf] end)

      name when name in @void_elements ->
        Agent.update(buffer, fn buf -> ["<#{name}#{compile_attrs(args)}>" | buf] end)

      name when name in [:for, :if, :unless] ->
        Agent.update(buffer, fn buf ->
          ["<%= " <> Macro.to_string({name, meta, args}) <> " do %>" | buf]
        end)

        traverse(buffer, do_and_else[:do])

        if Keyword.has_key?(do_and_else, :else) do
          Agent.update(buffer, fn buf -> ["<% else %>" | buf] end)
          traverse(buffer, do_and_else[:else])
        end

        Agent.update(buffer, fn buf -> ["<% end %>" | buf] end)

      _ ->
        Agent.update(buffer, fn buf -> ["<%= #{Macro.to_string(macro)} %>" | buf] end)
        traverse(buffer, do_and_else[:do])
    end
  end

  def traverse(buffer, [first | rest]) do
    traverse(buffer, first)

    traverse(buffer, rest)
  end

  def traverse(buffer, text) when is_binary(text) do
    Agent.update(buffer, fn buf -> [text | buf] end)
  end

  def traverse(_buffer, arg) when arg in [nil, []] do
    nil
  end

  defmacro temple([do: block] = _block) do
    {:ok, buffer} = Agent.start_link(fn -> [] end)

    buffer
    |> traverse(block)

    markup =
      buffer
      |> Agent.get(& &1)
      |> Enum.reverse()
      |> Enum.join("\n")

    quote location: :keep do
      unquote(markup)
    end
  end

  defmacro temple(block) do
    quote location: :keep do
      import Temple

      {:ok, buffer} = Agent.start_link(fn -> [] end)

      buffer
      |> traverse(unquote(block))

      markup =
        buffer
        |> Agent.get(& &1)
        |> Enum.reverse()
        |> Enum.join("\n")
    end
  end
end
