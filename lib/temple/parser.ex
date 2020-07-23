defmodule Temple.Parser do
  alias Temple.Buffer
  @components_path Application.get_env(:temple, :components_path, "./lib/components")

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

  defmodule Private do
    @moduledoc false

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
            Keyword.keyword?(arg) && (Keyword.keys(arg) -- [:do, :else]) |> Enum.count() == 0

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

    def traverse(buffer, {_name, _meta, _args} = original_macro) do
      Temple.Parser.parsers()
      |> Enum.reduce_while(original_macro, fn parser, macro ->
        with true <- parser.applicable?.(macro),
             :ok <- parser.parse.(macro, buffer) do
          {:halt, macro}
        else
          {:component_applied, adjusted_macro} ->
            traverse(buffer, adjusted_macro)

            {:halt, adjusted_macro}

          false ->
            {:cont, macro}
        end
      end)
    end

    def traverse(buffer, [first | rest]) do
      traverse(buffer, first)

      traverse(buffer, rest)
    end

    def traverse(buffer, text) when is_binary(text) do
      Buffer.put(buffer, text)
      Buffer.put(buffer, "\n")

      :ok
    end

    def traverse(_buffer, arg) when arg in [nil, []] do
      :ok
    end
  end

  def parsers(),
    do: [
      %{
        name: :temple_namespace_nonvoid,
        applicable?: fn {name, _meta, _args} ->
          try do
            {:., _, [{:__aliases__, _, [:Temple]}, name]} = name
            name in @nonvoid_elements_aliases
          rescue
            MatchError ->
              false
          end
        end,
        parse: fn {name, _meta, args}, buffer ->
          import Temple.Parser.Private
          {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

          {do_and_else, args} =
            args
            |> split_args()

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
        end
      },
      %{
        name: :temple_namespace_void,
        applicable?: fn {name, _meta, _args} ->
          try do
            {:., _, [{:__aliases__, _, [:Temple]}, name]} = name
            name in @void_elements_aliases
          rescue
            MatchError ->
              false
          end
        end,
        parse: fn {name, _, args}, buffer ->
          import Temple.Parser.Private
          {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

          {_do_and_else, args} =
            args
            |> split_args()

          name = @void_elements_lookup[name]

          Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
          Buffer.put(buffer, "\n")
        end
      },
      %{
        name: :components,
        applicable?: fn {name, meta, _} ->
          try do
            !meta[:temple_component_applied] &&
              File.exists?(Path.join([@components_path, "#{name}.exs"]))
          rescue
            _ ->
              false
          end
        end,
        parse: fn {name, _meta, args}, _buffer ->
          import Temple.Parser.Private

          {assigns, children} =
            case args do
              [assigns, [do: block]] ->
                {assigns, block}

              [[do: block]] ->
                {nil, block}

              [assigns] ->
                {assigns, nil}

              _ ->
                {nil, nil}
            end

          ast =
            File.read!(Path.join([@components_path, "#{name}.exs"]))
            |> Code.string_to_quoted!()

          {name, meta, args} =
            ast
            |> Macro.prewalk(fn
              {:@, _, [{:children, _, _}]} ->
                children

              {:@, _, [{:temple, _, _}]} ->
                assigns

              {:@, _, [{name, _, _}]} = node ->
                if !is_nil(assigns) && name in Keyword.keys(assigns) do
                  Keyword.get(assigns, name, nil)
                else
                  node
                end

              node ->
                node
            end)

          ast =
            if Enum.any?(
                 [
                   @nonvoid_elements,
                   @nonvoid_elements_aliases,
                   @void_elements,
                   @void_elements_aliases
                 ],
                 fn elements -> name in elements end
               ) do
              {name, Keyword.put(meta, :temple_component_applied, true), args}
            else
              {name, meta, args}
            end

          {:component_applied, ast}
        end
      },
      %{
        name: :nonvoid_elements_aliases,
        applicable?: fn {name, _, _} ->
          name in @nonvoid_elements_aliases
        end,
        parse: fn {name, _, args}, buffer ->
          import Temple.Parser.Private

          {do_and_else, args} =
            args
            |> split_args()

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
        end
      },
      %{
        name: :void_elements_aliases,
        applicable?: fn {name, _, _} ->
          name in @void_elements_aliases
        end,
        parse: fn {name, _, args}, buffer ->
          import Temple.Parser.Private

          {_do_and_else, args} =
            args
            |> split_args()

          name = @void_elements_lookup[name]

          Buffer.put(buffer, "<#{name}#{compile_attrs(args)}>")
          Buffer.put(buffer, "\n")
        end
      },
      %{
        name: :anonymous_functions,
        applicable?: fn {_, _, args} ->
          import Temple.Parser.Private, only: [split_args: 1]

          args |> split_args() |> elem(1) |> Enum.any?(fn x -> match?({:fn, _, _}, x) end)
        end,
        parse: fn {name, _, args}, buffer ->
          import Temple.Parser.Private

          {_do_and_else, args} =
            args
            |> split_args()

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
        end
      },
      %{
        name: :do_expressions,
        applicable?: fn
          {_, _, args} when is_list(args) ->
            Enum.any?(args, fn arg -> match?([{:do, _} | _], arg) end)

          _ ->
            false
        end,
        parse: fn {name, meta, args}, buffer ->
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
        end
      },
      %{
        name: :match,
        applicable?: fn {name, _, _} ->
          name in [:=]
        end,
        parse: fn {_, _, args} = macro, buffer ->
          import Temple.Parser.Private

          {do_and_else, _args} =
            args
            |> split_args()

          Buffer.put(buffer, "<% " <> Macro.to_string(macro) <> " %>")
          Buffer.put(buffer, "\n")
          traverse(buffer, do_and_else[:do])
        end
      },
      %{
        name: :default,
        applicable?: fn _ -> true end,
        parse: fn {_, _, args} = macro, buffer ->
          import Temple.Parser.Private

          {do_and_else, _args} =
            args
            |> split_args()

          Buffer.put(buffer, "<%= " <> Macro.to_string(macro) <> " %>")
          Buffer.put(buffer, "\n")
          traverse(buffer, do_and_else[:do])
        end
      }
    ]
end
