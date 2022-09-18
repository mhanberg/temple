defmodule Temple.Parser do
  @moduledoc false

  alias Temple.Parser.AnonymousFunctions
  alias Temple.Parser.Components
  alias Temple.Parser.Default
  alias Temple.Parser.DoExpressions
  alias Temple.Parser.Empty
  alias Temple.Parser.Match
  alias Temple.Parser.NonvoidElementsAliases
  alias Temple.Parser.RightArrow
  alias Temple.Parser.Slot
  alias Temple.Parser.TempleNamespaceNonvoid
  alias Temple.Parser.TempleNamespaceVoid
  alias Temple.Parser.Text
  alias Temple.Parser.VoidElementsAliases

  @aliases Application.compile_env(:temple, :aliases, [])

  # void tags
  # 'circle',
  #   'ellipse',
  #   'line',
  #   'path',
  #   'polygon',
  #   'polyline',
  #   'rect',
  #   'stop',
  #   'use'

  # nonvoid tags
  # 'a',
  #   'altGlyph',
  #   'altGlyphDef',
  #   'altGlyphItem',
  #   'animate',
  #   'animateColor',
  #   'animateMotion',
  #   'animateTransform',
  #   'animation',
  #   'audio',
  #   'canvas',
  #   'clipPath',
  #   'color-profile',
  #   'cursor',
  #   'defs',
  #   'desc',
  #   'discard',
  #   'feBlend',
  #   'feColorMatrix',
  #   'feComponentTransfer',
  #   'feComposite',
  #   'feConvolveMatrix',
  #   'feDiffuseLighting',
  #   'feDisplacementMap',
  #   'feDistantLight',
  #   'feDropShadow',
  #   'feFlood',
  #   'feFuncA',
  #   'feFuncB',
  #   'feFuncG',
  #   'feFuncR',
  #   'feGaussianBlur',
  #   'feImage',
  #   'feMerge',
  #   'feMergeNode',
  #   'feMorphology',
  #   'feOffset',
  #   'fePointLight',
  #   'feSpecularLighting',
  #   'feSpotLight',
  #   'feTile',
  #   'feTurbulence',
  #   'filter',
  #   'font',
  #   'font-face',
  #   'font-face-format',
  #   'font-face-name',
  #   'font-face-src',
  #   'font-face-uri',
  #   'foreignObject',
  #   'g',
  #   'glyph',
  #   'glyphRef',
  #   'handler',
  #   'hatch',
  #   'hatchpath',
  #   'hkern',
  #   'iframe',
  #   'image',
  #   'linearGradient',
  #   'listener',
  #   'marker',
  #   'mask',
  #   'mesh',
  #   'meshgradient',
  #   'meshpatch',
  #   'meshrow',
  #   'metadata',
  #   'missing-glyph',
  #   'mpath',
  #   'pattern',
  #   'prefetch',
  #   'radialGradient',
  #   'script',
  #   'set',
  #   'solidColor',
  #   'solidcolor',
  #   'style',
  #   'svg',
  #   'switch',
  #   'symbol',
  #   'tbreak',
  #   'text',
  #   'textArea',
  #   'textPath',
  #   'title',
  #   'tref',
  #   'tspan',
  #   'unknown',
  #   'video',
  #   'view',
  #   'vkern'

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

  def parsers() do
    [
      Empty,
      Text,
      TempleNamespaceNonvoid,
      TempleNamespaceVoid,
      Components,
      Slot,
      NonvoidElementsAliases,
      VoidElementsAliases,
      AnonymousFunctions,
      RightArrow,
      DoExpressions,
      Match,
      Default
    ]
  end

  def parse({:__block__, _, asts}) do
    parse(asts)
  end

  def parse(asts) when is_list(asts) do
    Enum.flat_map(asts, &parse/1)
  end

  def parse(ast) do
    with {_, false} <- {Empty, Empty.applicable?(ast)},
         {_, false} <- {Text, Text.applicable?(ast)},
         {_, false} <- {TempleNamespaceNonvoid, TempleNamespaceNonvoid.applicable?(ast)},
         {_, false} <- {TempleNamespaceVoid, TempleNamespaceVoid.applicable?(ast)},
         {_, false} <- {Components, Components.applicable?(ast)},
         {_, false} <- {Slot, Slot.applicable?(ast)},
         {_, false} <- {NonvoidElementsAliases, NonvoidElementsAliases.applicable?(ast)},
         {_, false} <- {VoidElementsAliases, VoidElementsAliases.applicable?(ast)},
         {_, false} <- {AnonymousFunctions, AnonymousFunctions.applicable?(ast)},
         {_, false} <- {RightArrow, RightArrow.applicable?(ast)},
         {_, false} <- {DoExpressions, DoExpressions.applicable?(ast)},
         {_, false} <- {Match, Match.applicable?(ast)},
         {_, false} <- {Default, Default.applicable?(ast)} do
      raise "No parsers applicable!"
    else
      {parser, true} ->
        ast
        |> parser.run()
        |> List.wrap()
    end
  end
end
