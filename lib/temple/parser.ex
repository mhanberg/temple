defmodule Temple.Parser do
  @moduledoc false

  @doc """
  Should return true if the parser should apply for the given AST.
  """
  @callback applicable?(ast :: Macro.t()) :: boolean()

  @doc """
  Processes the given AST, adding the markup to the given buffer.

  Should return `:ok` if the parsing pass is over, or `{:component_applied, ast}` if the pass should be restarted.
  """
  @callback run(ast :: Macro.t(), buffers :: %{atom() => pid()}, buffer :: atom()) :: %{
              atom() => pid()
            }
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
    {:ok, buffer} = Buffer.start_link()

    buffers = Temple.Parser.Private.traverse(%{default: buffer}, :default, ast)

    for {name, buffer} <- buffers, into: %{} do
      slot = Buffer.get(buffer, stop: true)

      {name, slot}
    end
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

    def traverse(buffers, buffer, {:__block__, _meta, block}) do
      traverse(buffers, buffer, block)
    end

    def traverse(buffers, buffer, [first | rest]) do
      buffers = traverse(buffers, buffer, first)

      traverse(buffers, buffer, rest)
    end

    def traverse(buffers, buffer, original_macro) do
      Temple.Parser.parsers()
      |> Enum.reduce_while(original_macro, fn parser, macro ->
        with true <-
               parser.applicable?(macro |> IO.inspect(label: "MACRO"))
               |> IO.inspect(label: "#{inspect(parser)}.applicable?"),
             buffers <- parser.run(macro, buffers, buffer) |> IO.inspect(label: "RUN") do
          {:halt, buffers}
        else
          false ->
            {:cont, macro}
        end
      end)
    end
  end
end
