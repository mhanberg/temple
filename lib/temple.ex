defmodule Temple do
  alias Temple.Buffer

  @aliases Application.get_env(:temple, :aliases, [])

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

  @nonvoid_elements_aliases Enum.map(@nonvoid_elements, fn el -> Keyword.get(@aliases, el, el) end)
  @nonvoid_elements_lookup Enum.map(@nonvoid_elements, fn el ->
                             {Keyword.get(@aliases, el, el), el}
                           end)

  @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

  @void_elements_aliases Enum.map(@void_elements, fn el -> Keyword.get(@aliases, el, el) end)
  @void_elements_lookup Enum.map(@void_elements, fn el -> {Keyword.get(@aliases, el, el), el} end)

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
    {do_and_else, args} =
      args
      |> Enum.split_with(fn
        arg when is_list(arg) ->
          Keyword.has_key?(arg, :do) || Keyword.has_key?(arg, :else)

        _ ->
          false
      end)

    {List.flatten(do_and_else), args}
  end

  def split_on_fn([{:fn, _, _} = func | rest], {args, _, args2}) do
    split_on_fn(rest, {args, func, args2})
  end

  def split_on_fn([arg | rest], {args, nil, args2}) do
    split_on_fn(rest, {[arg | args], nil, args2})
  end

  def split_on_fn([arg | rest], {args, func, args2}) do
    split_on_fn(rest, {args, func, [arg | args2]})
  end

  def split_on_fn([], {args, func, args2}) do
    {Enum.reverse(args), func, Enum.reverse(args2)}
  end

  def traverse(buffer, {:__block__, _meta, block}) do
    traverse(buffer, block)
  end

  def traverse(buffer, {name, meta, args} = macro) do
    {do_and_else, args} =
      args
      |> split_args()

    includes_fn? = args |> Enum.any?(fn x -> match?({:fn, _, _}, x) end)

    case name do
      {:., _, [{:__aliases__, _, [:Temple]}, name]} when name in @nonvoid_elements_aliases ->
        name = @nonvoid_elements_lookup[name]

        Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
        traverse(buffer, do_and_else[:do])
        Buffer.put(buffer, "</#{name}>")

      {:., _, [{:__aliases__, _, [:Temple]}, name]} when name in @void_elements_aliases ->
        name = @void_elements_lookup[name]

        Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")

      name when name in @nonvoid_elements_aliases ->
        name = @nonvoid_elements_lookup[name]

        Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
        traverse(buffer, do_and_else[:do])
        Buffer.put(buffer, "</#{name}>")

      name when name in @void_elements_aliases ->
        name = @void_elements_lookup[name]

        Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")

      name when includes_fn? ->
        {args, func_arg, args2} = split_on_fn(args, {[], nil, []})

        {func, _, [{arrow, _, [[{arg, _, _}], block]}]} = func_arg

        Buffer.put(
          buffer,
          "<%= " <>
            to_string(name) <>
            " " <>
            (Enum.map(args, &Macro.to_string(&1)) |> Enum.join(", ")) <>
            ", " <>
            to_string(func) <> " " <> to_string(arg) <> " " <> to_string(arrow) <> " %>"
        )

        traverse(buffer, block)

        if Enum.any?(args2) do
          Buffer.put(
            buffer,
            "<% end, " <>
              (Enum.map(args2, fn arg -> Macro.to_string(arg) end)
               |> Enum.join(", ")) <> " %>"
          )
        else
          Buffer.put(buffer, "<% end %>")
        end

      name when name in [:for, :if, :unless] ->
        Buffer.put(buffer, "<%= " <> Macro.to_string({name, meta, args}) <> " do %>")

        traverse(buffer, do_and_else[:do])

        if Keyword.has_key?(do_and_else, :else) do
          Buffer.put(buffer, "<% else %>")
          traverse(buffer, do_and_else[:else])
        end

        Buffer.put(buffer, "<% end %>")

      name when name in [:=] ->
        Buffer.put(buffer, "<% " <> Macro.to_string(macro) <> " %>")
        traverse(buffer, do_and_else[:do])

      _ ->
        Buffer.put(buffer, "<%= " <> Macro.to_string(macro) <> " %>")
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

  defmacro live_temple([do: block] = _block) do
    {:ok, buffer} = Buffer.start_link()

    buffer
    |> traverse(block)

    markup = Buffer.get(buffer)

    Buffer.stop(buffer)
    EEx.compile_string(markup, engine: Phoenix.LiveView.Engine)
  end
end
