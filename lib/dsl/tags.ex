defmodule Dsl.Tags do
  @nonvoid_elements ~w[
    html
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
    @doc """
    #{File.read!("./tmp/docs/#{el}.txt")}
    """
    defmacro unquote(el)() do
      el = unquote(el)

      quote do
        Dsl.Utils.put_open_tag(var!(buff, Dsl.Tags), unquote(el), [])
        Dsl.Utils.put_close_tag(var!(buff, Dsl.Tags), unquote(el))
      end
    end

    @doc false
    defmacro unquote(el)([{:do, inner}] = _attrs_or_content_or_block) do
      el = unquote(el)

      quote do
        Dsl.Utils.put_open_tag(var!(buff, Dsl.Tags), unquote(el), [])
        _ = unquote(inner)
        Dsl.Utils.put_close_tag(var!(buff, Dsl.Tags), unquote(el))
      end
    end

    defmacro unquote(el)(attrs_or_content_or_block) do
      el = unquote(el)

      quote do
        Dsl.Utils.put_open_tag(var!(buff, Dsl.Tags), unquote(el), unquote(attrs_or_content_or_block))
        Dsl.Utils.put_close_tag(var!(buff, Dsl.Tags), unquote(el))
      end
    end

    @doc false
    defmacro unquote(el)(attrs, [{:do, inner}] = _block) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)
        Dsl.Utils.put_open_tag(var!(buff, Dsl.Tags), unquote(el), attrs)
        _ = unquote(inner)
        Dsl.Utils.put_close_tag(var!(buff, Dsl.Tags), unquote(el))
      end
    end

    defmacro unquote(el)(content, attrs) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)
        Dsl.Utils.put_open_tag(var!(buff, Dsl.Tags), unquote(el), attrs)
        text unquote(content)
        Dsl.Utils.put_close_tag(var!(buff, Dsl.Tags), unquote(el))
      end
    end
  end

  for el <- @void_elements do
    @doc """
    #{File.read!("./tmp/docs/#{el}.txt")}
    """

    defmacro unquote(el)(attrs \\ []) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)

        Dsl.Utils.put_buffer(
          var!(buff, Dsl.Tags),
          "<#{unquote(el)}#{Dsl.Utils.compile_attrs(attrs)}>"
        )
      end
    end
  end
end
