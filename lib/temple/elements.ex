defmodule Temple.Elements do
  @moduledoc """
  This module contains the primitives used to generate the macros in the `Temple.Tags` and `Temple.Svg` modules. 
  """

  @doc """
  Defines an element.

  *Note*: Underscores are converted to dashes.

  ```elixir
  defmodule MyElements do
    import Temple.Elements

    defelement :super_select, :nonvoid # <super-select></super-select>
    defelement :super_input, :void     # <super-input>
  end
  ```
  """

  defmacro defelement(name, type)

  defmacro defelement(name, :nonvoid) do
    quote location: :keep do
      defmacro unquote(name)() do
        Temple.Elements.nonvoid_element(unquote(name))
      end

      @doc false
      defmacro unquote(name)(attrs_or_content_or_block)

      defmacro unquote(name)([{:do, _inner}] = block) do
        Temple.Elements.nonvoid_element(unquote(name), block)
      end

      defmacro unquote(name)(attrs_or_content) do
        Temple.Elements.nonvoid_element(unquote(name), attrs_or_content)
      end

      @doc false
      defmacro unquote(name)(attrs_or_content, block_or_attrs)

      defmacro unquote(name)(attrs, [{:do, _inner}] = block) do
        Temple.Elements.nonvoid_element(unquote(name), attrs, block)
      end

      defmacro unquote(name)(content, attrs) do
        Temple.Elements.nonvoid_element(unquote(name), content, attrs)
      end
    end
  end

  defmacro defelement(name, :void) do
    quote location: :keep do
      defmacro unquote(name)(attrs \\ []) do
        Temple.Elements.void_element(unquote(name), attrs)
      end
    end
  end

  @doc false
  def nonvoid_element(el) do
    quote location: :keep do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), [])
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  @doc false
  def nonvoid_element(el, attrs_or_content_or_block)

  def nonvoid_element(el, [{:do, inner}]) do
    quote location: :keep do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), [])
      _ = unquote(inner)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def nonvoid_element(el, attrs_or_content) do
    quote location: :keep do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote(el), unquote(attrs_or_content))
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  @doc false
  def nonvoid_element(el, attrs_or_content, block_or_attrs)

  def nonvoid_element(el, attrs, [{:do, inner}] = _block) do
    quote location: :keep do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
      _ = unquote(inner)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  def nonvoid_element(el, content, attrs) do
    quote location: :keep do
      Temple.Utils.put_open_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
      text unquote(content)
      Temple.Utils.put_close_tag(var!(buff, Temple.Tags), unquote(el))
    end
  end

  @doc false
  def void_element(el, attrs \\ []) do
    quote location: :keep do
      Temple.Utils.put_void_tag(var!(buff, Temple.Tags), unquote_splicing([el, attrs]))
    end
  end
end
