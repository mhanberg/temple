defmodule Dsl.Html do
  alias Phoenix.HTML

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
    map svg math
    table caption colgroup tbody thead tfoot tr td th
    form fieldset legend label button select datalist optgroup
    option textarea output progress meter
    details summary menuitem menu
  ]a

  @void_elements ~w[
    meta link base
    area br col embed hr img input keygen param source track wbr
  ]a

  defmacro htm(do: block) do
    quote do
      import Kernel, except: [div: 2]
      import HTML.Link, except: [link: 1, link: 2]

      {:ok, var!(buff, Dsl.Html)} = start_buffer([])

      unquote(block)

      markup = get_buffer(var!(buff, Dsl.Html))

      :ok = stop_buffer(var!(buff, Dsl.Html))

      markup |> Enum.reverse() |> Enum.join("") |> HTML.raw()
    end
  end

  for el <- @nonvoid_elements do
    defmacro unquote(el)() do
      el = unquote(el)

      quote do
        put_open_tag(var!(buff, Dsl.Html), unquote(el), [])
        put_close_tag(var!(buff, Dsl.Html), unquote(el))
      end
    end

    defmacro unquote(el)([{:do, inner} | attrs]) do
      el = unquote(el)

      quote do
        put_open_tag(var!(buff, Dsl.Html), unquote(el), unquote(attrs))
        _ = unquote(inner)
        put_close_tag(var!(buff, Dsl.Html), unquote(el))
      end
    end

    defmacro unquote(el)(attrs_or_content) do
      el = unquote(el)

      quote do
        put_open_tag(var!(buff, Dsl.Html), unquote(el), unquote(attrs_or_content))
        put_close_tag(var!(buff, Dsl.Html), unquote(el))
      end
    end

    defmacro unquote(el)(attrs, [{:do, inner}]) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)
        put_open_tag(var!(buff, Dsl.Html), unquote(el), attrs)
        _ = unquote(inner)
        put_close_tag(var!(buff, Dsl.Html), unquote(el))
      end
    end

    defmacro unquote(el)(content, attrs) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)
        put_open_tag(var!(buff, Dsl.Html), unquote(el), attrs)
        text unquote(content)
        put_close_tag(var!(buff, Dsl.Html), unquote(el))
      end
    end
  end

  def put_open_tag(buff, el, attrs) when is_list(attrs) do
    put_buffer(buff, "<#{el}#{compile_attrs(attrs)}>")
  end

  def put_open_tag(buff, el, content) when is_binary(content) do
    put_buffer(buff, "<#{el}>")
    put_buffer(buff, content)
  end

  def put_close_tag(buff, el) do
    put_buffer(buff, "</#{el}>")
  end

  for el <- @void_elements do
    defmacro unquote(el)(attrs \\ []) do
      el = unquote(el)

      quote do
        attrs = unquote(attrs)

        put_buffer(
          var!(buff, Dsl.Html),
          "<#{unquote(el)}#{compile_attrs(attrs)}>"
        )
      end
    end
  end

  defmacro text(text) do
    quote do
      put_buffer(
        var!(buff, Dsl.Html),
        unquote(text) |> to_string |> HTML.html_escape() |> HTML.safe_to_string()
      )
    end
  end

  defmacro javascript(code) do
    quote do
      put_buffer(
        var!(buff, Dsl.Html),
        unquote(code) |> to_string
      )
    end
  end

  defmacro partial(partial) do
    quote do
      put_buffer(
        var!(buff, Dsl.Html),
        unquote(partial) |> from_safe()
      )
    end
  end

  def from_safe({:safe, partial}) do
    partial
  end

  def from_safe(partial) do
    partial |> HTML.html_escape() |> HTML.safe_to_string()
  end

  defmacro defcomponent(name, do: block) do
    quote do
      defmacro unquote(name)(props \\ []) do
        outer = unquote(Macro.escape(block))
        name = unquote(name)

        {inner, props} = Keyword.pop(props, :do, nil)

        quote do
          unquote(name)(unquote(props), unquote(inner))
        end
      end

      defmacro unquote(name)(props, inner) do
        import Kernel, except: [div: 2]

        outer =
          unquote(Macro.escape(block))
          |> Macro.prewalk(&insert_props(&1, [{:children, inner} | props]))

        name = unquote(name)

        quote do
          unquote(outer)
        end
      end
    end
  end

  def insert_props({:@, _, [{name, _, _}]}, props) when is_atom(name) do
    props[name]
  end

  def insert_props(ast, _inner), do: ast

  def compile_attrs([]), do: ""

  def compile_attrs(attrs) do
    for {name, value} <- attrs, into: "" do
      name = name |> Atom.to_string() |> String.replace("_", "-")

      " " <> name <> "=\"" <> to_string(value) <> "\""
    end
  end

  def start_buffer(initial_buffer), do: Agent.start(fn -> initial_buffer end)
  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])
  def get_buffer(buff), do: Agent.get(buff, & &1)
  def stop_buffer(buff), do: Agent.stop(buff)
end
