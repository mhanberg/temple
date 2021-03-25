defmodule Temple.Parser do
  @moduledoc false

  alias Temple.Parser.Empty
  alias Temple.Parser.Text
  alias Temple.Parser.TempleNamespaceNonvoid
  alias Temple.Parser.TempleNamespaceVoid
  alias Temple.Parser.Components
  alias Temple.Parser.NonvoidElementsAliases
  alias Temple.Parser.VoidElementsAliases
  alias Temple.Parser.AnonymousFunctions
  alias Temple.Parser.RightArrow
  alias Temple.Parser.DoExpressions
  alias Temple.Parser.Match
  alias Temple.Parser.Default

  @doc """
  Should return true if the parser should apply for the given AST.
  """
  @callback applicable?(ast :: Macro.t()) :: boolean()

  @doc """
  Processes the given AST, adding the markup to the given buffer.

  Should return `:ok` if the parsing pass is over, or `{:component_applied, ast}` if the pass should be restarted.
  """
  @callback run(ast :: Macro.t(), buffer :: pid()) :: :ok | {:component_applied, Macro.t()}

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

  @nonvoid_elements_aliases Enum.map(@nonvoid_elements, fn el ->
                              Keyword.get(@aliases, el, el)
                            end)
  @nonvoid_elements_lookup Enum.map(@nonvoid_elements, fn el ->
                             {Keyword.get(@aliases, el, el), el}
                           end)

  def nonvoid_elements, do: @nonvoid_elements
  def nonvoid_elements_aliases, do: @nonvoid_elements_aliases
  def nonvoid_elements_lookup, do: @nonvoid_elements_lookup

  @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

  @void_elements_aliases Enum.map(@void_elements, fn el -> Keyword.get(@aliases, el, el) end)
  @void_elements_lookup Enum.map(@void_elements, fn el ->
                          {Keyword.get(@aliases, el, el), el}
                        end)

  def void_elements, do: @void_elements
  def void_elements_aliases, do: @void_elements_aliases
  def void_elements_lookup, do: @void_elements_lookup

  def parsers(),
    do: [
      Temple.Parser.Empty,
      Temple.Parser.Text,
      Temple.Parser.TempleNamespaceNonvoid,
      Temple.Parser.TempleNamespaceVoid,
      Temple.Parser.Components,
      Temple.Parser.NonvoidElementsAliases,
      Temple.Parser.VoidElementsAliases,
      Temple.Parser.AnonymousFunctions,
      Temple.Parser.RightArrow,
      Temple.Parser.DoExpressions,
      Temple.Parser.Match,
      Temple.Parser.Default
    ]

  def parse(ast) do
    with {_, false} <- {Empty, Empty.applicable?(ast)},
         {_, false} <- {Text, Text.applicable?(ast)},
         {_, false} <- {TempleNamespaceNonvoid, TempleNamespaceNonvoid.applicable?(ast)},
         {_, false} <- {TempleNamespaceVoid, TempleNamespaceVoid.applicable?(ast)},
         {_, false} <- {Components, Components.applicable?(ast)},
         {_, false} <- {NonvoidElementsAliases, NonvoidElementsAliases.applicable?(ast)},
         {_, false} <- {VoidElementsAliases, VoidElementsAliases.applicable?(ast)},
         {_, false} <- {AnonymousFunctions, AnonymousFunctions.applicable?(ast)},
         {_, false} <- {RightArrow, RightArrow.applicable?(ast)},
         {_, false} <- {DoExpressions, DoExpressions.applicable?(ast)},
         {_, false} <- {Match, Match.applicable?(ast)},
         {_, false} <- {Default, Default.applicable?(ast)} do
      raise "No parsers applicable!!"
    else
      {parser, true} ->
        ast
        |> parser.run()
        |> List.wrap()
    end
  end

  def old_parse(ast) do
    {:ok, buffer} = Buffer.start_link()

    Temple.Parser.Private.traverse(buffer, ast)
    markup = Buffer.get(buffer)

    Buffer.stop(buffer)

    markup
  end

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

    def compile_attrs(attrs) when is_list(attrs) do
      if Keyword.keyword?(attrs) do
        for {name, value} <- attrs, into: "" do
          name = snake_to_kebab(name)

          case value do
            {_, _, _} = macro ->
              " " <> name <> "=\"<%= " <> Macro.to_string(macro) <> " %>\""

            value ->
              " " <> name <> "=\"" <> to_string(value) <> "\""
          end
        end
      else
        "<%= Temple.Parser.Private.runtime_attrs(" <>
          (attrs |> List.first() |> Macro.to_string()) <> ") %>"
      end
    end

    def runtime_attrs(attrs) do
      {:safe,
       for {name, value} <- attrs, into: "" do
         name = snake_to_kebab(name)

         " " <> name <> "=\"" <> to_string(value) <> "\""
       end}
    end

    def split_args(not_what_i_want) when is_nil(not_what_i_want) or is_atom(not_what_i_want),
      do: {[], []}

    def split_args(args) do
      {do_and_else, args} =
        args
        |> Enum.split_with(fn arg ->
          if Keyword.keyword?(arg) do
            arg
            |> Keyword.drop([:do, :else])
            |> Enum.empty?()
          else
            false
          end
        end)

      {List.flatten(do_and_else), args}
    end

    def split_on_fn([{:fn, _, _} = func | rest], {args_before, _, args_after}) do
      split_on_fn(rest, {args_before, func, args_after})
    end

    def split_on_fn([arg | rest], {args_before, nil, args_after}) do
      split_on_fn(rest, {[arg | args_before], nil, args_after})
    end

    def split_on_fn([arg | rest], {args_before, func, args_after}) do
      split_on_fn(rest, {args_before, func, [arg | args_after]})
    end

    def split_on_fn([], {args_before, func, args_after}) do
      {Enum.reverse(args_before), func, Enum.reverse(args_after)}
    end

    def pop_compact?([]), do: {false, []}
    def pop_compact?([args]) when is_list(args), do: pop_compact?(args)

    def pop_compact?(args) do
      Keyword.pop(args, :compact, false)
    end

    def traverse(buffer, {:__block__, _meta, block}) do
      traverse(buffer, block)
    end

    def traverse(buffer, [first | rest]) do
      traverse(buffer, first)

      traverse(buffer, rest)
    end

    def traverse(buffer, original_macro) do
      Temple.Parser.parsers()
      |> Enum.reduce_while(original_macro, fn parser, macro ->
        with true <- parser.applicable?(macro),
             :ok <- parser.run(macro, buffer) do
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
  end
end
