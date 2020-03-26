defmodule Temple.Svg do
  require Temple.Elements

  @moduledoc """
  The `Temple.Svg` module defines macros for all SVG elements.

  Usage is the same as `Temple.Html`.
  """

  @elements ~w[
    animate animateMotion animateTransform circle clipPath
    color_profile defs desc discard ellipse feBlend
    feColorMatrix feComponentTransfer feComposite feConvolveMatrix feDiffuseLighting feDisplacementMap feDistantLight feDropShadow
    feFlood feFuncA feFuncB feFuncG feFuncR feGaussianBlur feImage feMerge feMergeNode feMorphology feOffset
    fePointLight feSpecularLighting feSpotLight feTile feTurbulence filter foreignObject g hatch hatchpath image line linearGradient
    marker mask metadata mpath path pattern polygon
    polyline radialGradient rect set solidcolor stop svg switch symbol text_
    textPath tspan use view
  ]a

  @doc false
  def elements(), do: @elements

  for el <- @elements do
    Temple.Elements.defelement(unquote(el), :nonvoid)
  end
end
