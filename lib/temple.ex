defmodule Temple do
  alias Temple.Buffer

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

  defmacro __using__(:live) do
    quote location: :keep do
      @before_compile Temple.Renderer
    end
  end

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
    for {name, value} <- attrs, into: "" do
      name = snake_to_kebab(name)

      case value do
        {_, _, _} = macro ->
          " " <> name <> "=\"<%= " <> Macro.to_string(macro) <> " %>\""

        value ->
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
      :eval ->
        Buffer.put(buffer, "<% " <> Macro.to_string(do_and_else[:do]) <> " %>")

      name when name in @nonvoid_elements ->
        Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
        traverse(buffer, do_and_else[:do])
        Buffer.put(buffer, "</#{name}>")

      name when name in @void_elements ->
        Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")

      name when name in [:for, :if, :unless] ->
        Buffer.put(buffer, "<%= " <> Macro.to_string({name, meta, args}) <> " do %>")

        traverse(buffer, do_and_else[:do])

        if Keyword.has_key?(do_and_else, :else) do
          Buffer.put(buffer, "<% else %>")
          traverse(buffer, do_and_else[:else])
        end

        Buffer.put(buffer, "<% end %>")

      _ ->
        Buffer.put(buffer, "<%= #{Macro.to_string(macro)} %>")
        traverse(buffer, do_and_else[:do])
    end
  end

  def traverse(buffer, [first | rest]) do
    traverse(buffer, first)

    traverse(buffer, rest)
  end

  def traverse(buffer, text) when is_binary(text) do
    Buffer.put(buffer, text)
  end

  def traverse(_buffer, arg) when arg in [nil, []] do
    nil
  end

  defmacro temple([do: block] = _block) do
    {:ok, buffer} = Buffer.start_link()

    buffer
    |> traverse(block)

    markup = Buffer.get(buffer)

    Buffer.stop(buffer)

    quote location: :keep do
      unquote(markup)
    end
  end

  defmacro temple(block) do
    quote location: :keep do
      import Temple

      {:ok, buffer} = Buffer.start_link()

      buffer
      |> traverse(unquote(block))

      markup = Buffer.get(buffer)

      Buffer.stop(buffer)

      markup
    end
  end
end
