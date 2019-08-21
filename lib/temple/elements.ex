defmodule Temple.Elements do
  def nonvoid_element(el) do
    quote do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), [])
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def nonvoid_element(el, attrs_or_content_or_block)

  def nonvoid_element(el, [{:do, inner}]) do
    quote do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), [])
      _ = unquote(inner)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def nonvoid_element(el, attrs_or_content) do
    quote do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), unquote(attrs_or_content))
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def nonvoid_element(el, attrs_or_content, block_or_attrs)

  def nonvoid_element(el, attrs, [{:do, inner}] = _block) do
    quote do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
      _ = unquote(inner)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def nonvoid_element(el, content, attrs) do
    quote do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
      text unquote(content)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def void_element(el, attrs \\ []) do
    quote do
      attrs = unquote(attrs)

      Temple.Utils.put_buffer(
        var!(buff, Temple.Tags),
        "<#{unquote(el)}#{Temple.Utils.compile_attrs(attrs)}>"
      )
    end
  end
end
