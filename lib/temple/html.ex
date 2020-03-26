defmodule Temple.Html do
  require Temple.Elements

  @moduledoc """
  The `Temple.Html` module defines macros for all HTML5 compliant elements.

  `Temple.Html` macros must be called inside of a `Temple.temple/1` block.

  *Note*: Only the lowest arity macros are documented. Void elements are defined as a 1-arity macro and non-void elements are defined as 0, 1, and 2-arity macros.

  ## Attributes

  Html accept a keyword list or a map of attributes to be emitted into the element's opening tag. Multi-word attribute keys written in snake_case (`data_url`) will be transformed into kebab-case (`data-url`).

  ## Children

  Non-void elements (such as `div`) accept a block that can be used to nest other tags or text nodes. These blocks can contain arbitrary Elixir code such as variables and for comprehensions.

  If you are only emitting a text node within a block, you can use the shortened syntax by passing the text in as the first parameter of the tag.

  ## Example

  ```
  temple do
    # empty non-void element
    div()

    # non-void element with keyword list attributes
    div class: "text-red", id: "my-el"

    # non-void element with map attributes
    div %{:class => "text-red", "id" => "my-el"}

    # non-void element with children
    div do
      text "Hello, world!"
      
      for name <- @names do
        div data_name: name
      end
    end

    # non-void element with a single text node
    div "Hello, world!", class: "text-green"
    
    # void elements
    input name: "comments", placeholder: "Enter a comment..."
  end

  # {:safe,
  #  "<div></div>
  #   <div class=\"text-red\" id=\"my-el\"></div>
  #   <div>
  #     Hello, world!
  #     <div data-name=\"Alice\"></div>
  #     <div data-name=\"Bob\"></div>
  #     <div data-name=\"Carol\"></div>
  #   </div>
  #   <div class=\"text-green\">Hello, world!</div>
  #   <input name=\"comments\" placeholder=\"Enter a comment...\">"
  # }
  ```
  """

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
  ]a

  @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

  @doc false
  def nonvoid_elements, do: @nonvoid_elements
  @doc false
  def void_elements, do: @void_elements

  for el <- @nonvoid_elements do
    Temple.Elements.defelement(unquote(el), :nonvoid)
  end

  for el <- @void_elements do
    Temple.Elements.defelement(unquote(el), :void)
  end

  defmacro html(attrs \\ [], [{:do, _inner}] = block) do
    doc_type =
      quote location: :keep do
        Temple.Utils.put_buffer(var!(buff, Temple.Html), "<!DOCTYPE html>")
      end

    [doc_type, Temple.Elements.nonvoid_element(:html, attrs, block)]
  end
end
