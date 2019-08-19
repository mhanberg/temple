defmodule Temple.Tags do
  @moduledoc """
  The `Temple.Tags` module defines macros for all HTML5 compliant elements.

  `Temple.Tags` macros must be called inside of a `Temple.temple/1` block.

  ## Attributes

  Tags accept a keyword list or a map of attributes to be emitted into the element's opening tag. Multi-word attribute keys written in snake_case (`data_url`) will be transformed into kebab-case (`data-url`).

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
  #
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
    @doc if File.exists?("./tmp/docs/#{el}.txt"), do: File.read!("./tmp/docs/#{el}.txt")
    defmacro unquote(el)() do
      el = unquote(el)

      quote do
        Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), [])
        Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
      end
    end

    defmacro unquote(el)(attrs_or_content_or_block)

    defmacro unquote(el)([{:do, inner}]) do
      el = unquote(el)

      quote do
        Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), [])
        _ = unquote(inner)
        Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
      end
    end

    defmacro unquote(el)(attrs_or_content) do
      el = unquote(el)

      quote do
        Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), unquote(attrs_or_content))
        Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
      end
    end

    defmacro unquote(el)(attrs_or_content, block_or_attrs)

    defmacro unquote(el)(attrs, [{:do, inner}] = _block) do
      el = unquote(el)

      quote do
        Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
        _ = unquote(inner)
        Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
      end
    end

    defmacro unquote(el)(content, attrs) do
      el = unquote(el)

      quote do
        Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
        text unquote(content)
        Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
      end
    end
  end

  for el <- @void_elements do
    @doc if File.exists?("./tmp/docs/#{el}.txt"), do: File.read!("./tmp/docs/#{el}.txt")
    defmacro unquote(el)(attrs \\ []) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)

        Temple.Utils.put_buffer(
          var!(buff, Temple.Tags),
          "<#{unquote(el)}#{Temple.Utils.compile_attrs(attrs)}>"
        )
      end
    end
  end

  @doc if File.exists?("./tmp/docs/html.txt"), do: File.read!("./tmp/docs/html.txt")
  defmacro unquote(:html)() do
    quote do
      Temple.Utils.put_buffer(var!(buff, Temple.Tags), "<!DOCTYPE html>")
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(:html), [])
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(:html))
    end
  end

  defmacro unquote(:html)(attrs_or_content_or_block)

  defmacro unquote(:html)([{:do, inner}]) do
    quote do
      Temple.Utils.put_buffer(var!(buff, Temple.Tags), "<!DOCTYPE html>")
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(:html), [])
      _ = unquote(inner)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(:html))
    end
  end

  defmacro unquote(:html)(attrs_or_content) do
    quote do
      Temple.Utils.put_buffer(var!(buff, Temple.Tags), "<!DOCTYPE html>")

      Temple.Utils.put_open_tag(
        var!(buff, Temple.Tags),
        unquote(:html),
        unquote(attrs_or_content)
      )

      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(:html))
    end
  end

  defmacro unquote(:html)(attrs_or_content, block_or_attrs)

  defmacro unquote(:html)(attrs, [{:do, inner}] = _block) do
    quote do
      Temple.Utils.put_buffer(var!(buff, Temple.Tags), "<!DOCTYPE html>")
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([:html, attrs]))
      _ = unquote(inner)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(:html))
    end
  end

  defmacro unquote(:html)(content, attrs) do
    quote do
      Temple.Utils.put_buffer(var!(buff, Temple.Tags), "<!DOCTYPE html>")
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([:html, attrs]))
      text unquote(content)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(:html))
    end
  end
end
