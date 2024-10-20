temple = ~w[temple c slot]a

html = ~w[
  html head title style script
  noscript template
  body section nav article aside h1 h2 h3 h4 h5 h6
  header footer address main
  p pre blockquote ol ul li dl dt dd figure figcaption div
  a em strong small s cite q dfn abbr data time code var samp kbd
  sub sup i b u mark ruby rt rp bdi bdo span
  ins del
  iframe object video audio canvas
  map svg math
  table caption colgroup tbody thead tfoot tr td th
  form fieldset legend label button select datalist optgroup
  option textarea output progress meter
  details summary menuitem menu
  meta link base
  area br col embed hr img input keygen param source track wbr
]a

svg = ~w[
  circle ellipse line path polygon polyline rect stop use a
  altGlyph altGlyphDef altGlyphItem animate animateColor animateMotion
  animateTransform animation audio canvas clipPath cursor defs desc
  discard feBlend feColorMatrix feComponentTransfer feComposite
  feConvolveMatrix feDiffuseLighting feDisplacementMap feDistantLight
  feDropShadow feFlood feFuncA feFuncB feFuncG feFuncR feGaussianBlur
  feImage feMerge feMergeNode feMorphology feOffset fePointLight
  feSpecularLighting feSpotLight feTile feTurbulence filter font
  foreignObject g glyph glyphRef handler hatch hatchpath hkern iframe
  image linearGradient listener marker mask mesh meshgradient meshpatch
  meshrow metadata mpath pattern prefetch radialGradient script set
  solidColor solidcolor style svg switch symbol tbreak text textArea
  textPath title tref tspan unknown video view vkern
]a

mathml = ~w[
  math mi mn mo ms mspace mtext
  merror mfrac mpadded mphantom mroot mrow msqrt mstyle
  mmultiscripts mover msub msubsup msup munder munderover
  mtable mtd mtr annotation semantics mprescripts
]a

locals_without_parens = Enum.map(temple ++ html ++ svg ++ mathml, &{&1, :*})

[
  import_deps: [:typed_struct],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens ++ [assert_html: 2],
  export: [locals_without_parens: locals_without_parens]
]
