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
  @callback run(ast :: Macro.t(), buffer :: pid()) :: :ok | {:component_applied, Macro.t()}

  alias Temple.Buffer
  alias Temple.Parser.Utils

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

    Utils.traverse(buffer, ast)
    markup = Buffer.get(buffer)

    Buffer.stop(buffer)

    markup
  end
end
