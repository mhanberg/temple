locals_without_parens = ~w[
  temple c slot
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
  option text_area output progress meter
  details summary menuitem menu
  meta link base
  area br col embed hr img input keygen param source track wbr

  animate animateMotion animateTransform circle clipPath
  color-profile defs desc discard ellipse feBlend
  feColorMatrix feComponentTransfer feComposite feConvolveMatrix feDiffuseLighting feDisplacementMap feDistantLight feDropShadow
  feFlood feFuncA feFuncB feFuncG feFuncR feGaussianBlur feImage feMerge feMergeNode feMorphology feOffset
  fePointLight feSpecularLighting feSpotLight feTile feTurbulence filter foreignObject g hatch hatchpath image line linearGradient
  marker mask mesh meshgradient meshpatch meshrow metadata mpath path pattern polygon
  polyline radialGradient rect set solidcolor stop svg switch symbol text
  textPath tspan unknown use view
]a |> Enum.map(fn e -> {e, :*} end)

[
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
