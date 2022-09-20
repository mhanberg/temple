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

  @doc """
  Should return true if the parser should apply for the given AST.
  """
  @callback applicable?(ast :: Macro.t()) :: boolean()

  @doc """
  Processes the given AST, adding the markup to the given buffer.

  Should return Temple.AST.
  """
  @callback run(ast :: Macro.t()) :: Temple.Ast.t()

  @void_svg_lookup [
    circle: "circle",
    ellipse: "ellipse",
    line: "line",
    path: "path",
    polygon: "polygon",
    polyline: "polyline",
    rect: "rect",
    stop: "stop",
    use: "use"
  ]

  @void_svg_aliases Keyword.keys(@void_svg_lookup)

  @nonvoid_svg_lookup [
    a: "a",
    altGlyph: "altGlyph",
    altGlyphDef: "altGlyphDef",
    altGlyphItem: "altGlyphItem",
    animate: "animate",
    animateColor: "animateColor",
    animateMotion: "animateMotion",
    animateTransform: "animateTransform",
    animation: "animation",
    audio: "audio",
    canvas: "canvas",
    clipPath: "clipPath",
    color_profile: "color-profile",
    cursor: "cursor",
    defs: "defs",
    desc: "desc",
    discard: "discard",
    feBlend: "feBlend",
    feColorMatrix: "feColorMatrix",
    feComponentTransfer: "feComponentTransfer",
    feComposite: "feComposite",
    feConvolveMatrix: "feConvolveMatrix",
    feDiffuseLighting: "feDiffuseLighting",
    feDisplacementMap: "feDisplacementMap",
    feDistantLight: "feDistantLight",
    feDropShadow: "feDropShadow",
    feFlood: "feFlood",
    feFuncA: "feFuncA",
    feFuncB: "feFuncB",
    feFuncG: "feFuncG",
    feFuncR: "feFuncR",
    feGaussianBlur: "feGaussianBlur",
    feImage: "feImage",
    feMerge: "feMerge",
    feMergeNode: "feMergeNode",
    feMorphology: "feMorphology",
    feOffset: "feOffset",
    fePointLight: "fePointLight",
    feSpecularLighting: "feSpecularLighting",
    feSpotLight: "feSpotLight",
    feTile: "feTile",
    feTurbulence: "feTurbulence",
    filter: "filter",
    font: "font",
    font_face: "font-face",
    font_face_format: "font-face-format",
    font_face_name: "font-face-name",
    font_face_src: "font-face-src",
    font_face_uri: "font-face-uri",
    foreignObject: "foreignObject",
    g: "g",
    glyph: "glyph",
    glyphRef: "glyphRef",
    handler: "handler",
    hatch: "hatch",
    hatchpath: "hatchpath",
    hkern: "hkern",
    iframe: "iframe",
    image: "image",
    linearGradient: "linearGradient",
    listener: "listener",
    marker: "marker",
    mask: "mask",
    mesh: "mesh",
    meshgradient: "meshgradient",
    meshpatch: "meshpatch",
    meshrow: "meshrow",
    metadata: "metadata",
    missing_glyph: "missing-glyph",
    mpath: "mpath",
    pattern: "pattern",
    prefetch: "prefetch",
    radialGradient: "radialGradient",
    script: "script",
    set: "set",
    solidColor: "solidColor",
    solidcolor: "solidcolor",
    style: "style",
    svg: "svg",
    switch: "switch",
    symbol: "symbol",
    tbreak: "tbreak",
    text: "text",
    textArea: "textArea",
    textPath: "textPath",
    title: "title",
    tref: "tref",
    tspan: "tspan",
    unknown: "unknown",
    video: "video",
    view: "view",
    vkern: "vkern"
  ]

  @nonvoid_svg_aliases Keyword.keys(@nonvoid_svg_lookup)

  # nonvoid tags

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

  def nonvoid_elements, do: @nonvoid_elements ++ Keyword.values(@nonvoid_svg_aliases)
  def nonvoid_elements_aliases, do: @nonvoid_elements_aliases ++ @nonvoid_svg_aliases
  def nonvoid_elements_lookup, do: @nonvoid_elements_lookup ++ @nonvoid_svg_lookup

  @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

  @void_elements_aliases Enum.map(@void_elements, fn el -> Keyword.get(@aliases, el, el) end)
  @void_elements_lookup Enum.map(@void_elements, fn el ->
                          {Keyword.get(@aliases, el, el), el}
                        end)

  def void_elements, do: @void_elements ++ Keyword.values(@void_svg_aliases)
  def void_elements_aliases, do: @void_elements_aliases ++ @void_svg_aliases
  def void_elements_lookup, do: @void_elements_lookup ++ @void_svg_lookup

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
