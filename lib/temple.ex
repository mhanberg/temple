defmodule Temple do
  alias Temple.Buffer

  @moduledoc """
  > Warning: Docs are WIP

  Temple syntax is available inside the `temple` and `live_temple` macros, and is compiled into EEx at build time.

  ### Usage

  ```elixir
  temple do
    # You can define attributes by passing a keyword list to the element, the values can be literals or variables.
    class = "text-blue"
    id = "jumbotron"

    div class: class, id: id do
      # Text nodes can be emitted as string literals or variables.
      "Bob"

      id
    end

    # if and unless expressions can be used to conditionally render content
    if 5 > 0 do
      p do
        "Greater than 0!"
      end
    end

    unless 5 > 0 do
      p do
        "Less than 0!"
      end
    end

    # You can loop over items using for comprehensions
    for x <- 0..5 do
      div do
        x
      end
    end

    # You can use multiline anonymous functions, like if you're building a form in Phoenix
    form_for @changeset, Routes.user_path(@conn, :create), fn f ->
      "Name: "
      text_input f, :name
    end

    # You can explicitly call a tag by prefixing with the Temple module
    Temple.div do
      "Foo"
    end

    # You can also pass children as a do key instead of a block
    div do: "Alice", class: "text-yellow"
  end
  ```

  ### Reserved keywords

  You can pass a keyword list to an element as element attributes, but there are several reserved keywords.

  #### Compact

  Passing `compact: true` will not rendering new lines from within the element. This is useful if you are trying to use the `:empty` psuedo selector.

  ```elixir
  temple do
    p compact: true do
      "Foo"
    end
    p do
      "Bar"
    end
  end
  ```

  would evaluate to

  ```html
  <p>Foo</p>
  <p>
  Bar
  </p>
  ```

  ### Configuration

  #### Aliases

  You can add an alias for an element if there is a namespace collision with a function. If you are using `Phoenix.HTML`, there will be namespace collisions with the `<link>` and `<label>` elements.

  ```elixir
  config :temple, :aliases,
    label: :_label,
    link: :_link

  temple do
    _label do
      "Email"
    end

    _link href: "/css/site.css"
  end
  ```

  This will result in:

  ```html
  <label>
    Email
  </label>

  <link href="/css/site.css">
  ```
  """

  defmacro __using__(_) do
    quote location: :keep do
      import Temple
    end
  end

  defmodule Private do
    @moduledoc false
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

    @nonvoid_elements_aliases Enum.map(@nonvoid_elements, fn el ->
                                Keyword.get(@aliases, el, el)
                              end)
    @nonvoid_elements_lookup Enum.map(@nonvoid_elements, fn el ->
                               {Keyword.get(@aliases, el, el), el}
                             end)

    @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

    @void_elements_aliases Enum.map(@void_elements, fn el -> Keyword.get(@aliases, el, el) end)
    @void_elements_lookup Enum.map(@void_elements, fn el ->
                            {Keyword.get(@aliases, el, el), el}
                          end)

    def snake_to_kebab(stringable),
      do:
        stringable |> to_string() |> String.replace_trailing("_", "") |> String.replace("_", "-")

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
            (Keyword.keys(arg) -- [:do, :else]) |> Enum.count() == 0

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

    def pop_compact?([]), do: {false, []}
    def pop_compact?([args]) when is_list(args), do: pop_compact?(args)

    def pop_compact?(args) do
      Keyword.pop(args, :compact, false)
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
          {do_and_else, args} =
            case args do
              [args] ->
                {do_value, args} = Keyword.pop(args, :do)

                do_and_else = Keyword.put_new(do_and_else, :do, do_value)

                {do_and_else, args}

              _ ->
                {do_and_else, args}
            end

          name = @nonvoid_elements_lookup[name]

          {compact?, args} = pop_compact?(args)

          Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
          unless compact?, do: Buffer.put(buffer, "\n")
          traverse(buffer, do_and_else[:do])
          if compact?, do: Buffer.remove_new_line(buffer)
          Buffer.put(buffer, "</#{name}>")
          Buffer.put(buffer, "\n")

        {:., _, [{:__aliases__, _, [:Temple]}, name]} when name in @void_elements_aliases ->
          name = @void_elements_lookup[name]

          Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
          Buffer.put(buffer, "\n")

        name when name in @nonvoid_elements_aliases ->
          {do_and_else, args} =
            case args do
              [args] ->
                {do_value, args} = Keyword.pop(args, :do)

                do_and_else = Keyword.put_new(do_and_else, :do, do_value)

                {do_and_else, args}

              _ ->
                {do_and_else, args}
            end

          name = @nonvoid_elements_lookup[name]

          {compact?, args} = pop_compact?(args)

          Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
          unless compact?, do: Buffer.put(buffer, "\n")
          traverse(buffer, do_and_else[:do])
          if compact?, do: Buffer.remove_new_line(buffer)
          Buffer.put(buffer, "</#{name}>")
          Buffer.put(buffer, "\n")

        name when name in @void_elements_aliases ->
          name = @void_elements_lookup[name]

          Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
          Buffer.put(buffer, "\n")

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

          Buffer.put(buffer, "\n")

          traverse(buffer, block)

          if Enum.any?(args2) do
            Buffer.put(
              buffer,
              "<% end, " <>
                (Enum.map(args2, fn arg -> Macro.to_string(arg) end)
                 |> Enum.join(", ")) <> " %>"
            )

            Buffer.put(buffer, "\n")
          else
            Buffer.put(buffer, "<% end %>")
            Buffer.put(buffer, "\n")
          end

        name when name in [:for, :if, :unless] ->
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

        name when name in [:=] ->
          Buffer.put(buffer, "<% " <> Macro.to_string(macro) <> " %>")
          Buffer.put(buffer, "\n")
          traverse(buffer, do_and_else[:do])

        _ ->
          Buffer.put(buffer, "<%= " <> Macro.to_string(macro) <> " %>")
          Buffer.put(buffer, "\n")
          traverse(buffer, do_and_else[:do])
      end
    end

    def traverse(buffer, [first | rest]) do
      traverse(buffer, first)

      traverse(buffer, rest)
    end

    def traverse(buffer, text) when is_binary(text) do
      Buffer.put(buffer, text)
      Buffer.put(buffer, "\n")
    end

    def traverse(_buffer, arg) when arg in [nil, []] do
      nil
    end
  end

  defmacro temple([do: block] = _block) do
    {:ok, buffer} = Buffer.start_link()

    buffer
    |> Temple.Private.traverse(block)

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
      |> Temple.Private.traverse(unquote(block))

      markup = Buffer.get(buffer)

      Buffer.stop(buffer)

      markup
    end
  end

  defmacro live_temple([do: block] = _block) do
    {:ok, buffer} = Buffer.start_link()

    buffer
    |> Temple.Private.traverse(block)

    markup = Buffer.get(buffer)

    Buffer.stop(buffer)
    EEx.compile_string(markup, engine: Phoenix.LiveView.Engine)
  end
end
