defmodule Dsl.Html do
  alias Phoenix.HTML

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

  defmacro htm(opts) do
    quote do
      htm(unquote(Keyword.get(opts, :safe, false)), unquote(opts[:do]))
    end
  end

  defmacro htm(safe?, block) do
    quote do
      import Kernel, except: [div: 2]

      {:ok, var!(buff, Dsl.Html)} = start_buffer([])

      unquote(block)

      markup = get_buffer(var!(buff, Dsl.Html))

      :ok = stop_buffer(var!(buff, Dsl.Html))

      if unquote(safe?) do
        markup |> Enum.reverse() |> Enum.join("") |> HTML.html_escape()
      else
        markup |> Enum.reverse() |> Enum.join("")
      end
    end
  end

  for el <- @nonvoid_elements do
    defmacro unquote(el)(attrs \\ [])

    defmacro unquote(el)(attrs) do
      el = unquote(el)
      {inner, attrs} = Keyword.pop(attrs, :do, nil)

      quote do
        unquote(el)(unquote(attrs), unquote(inner))
      end
    end

    defmacro unquote(el)(attrs, inner) do
      el = unquote(el)

      quote do
        put_buffer(var!(buff, Dsl.Html), "<#{unquote(el)}#{unquote(compile_attrs(attrs))}>")
        unquote(inner)
        put_buffer(var!(buff, Dsl.Html), "</#{unquote(el)}>")
      end
    end
  end

  for el <- @void_elements do
    defmacro unquote(el)(attrs \\ [])

    defmacro unquote(el)(attrs) do
      el = unquote(el)

      quote do
        put_buffer(
          var!(buff, Dsl.Html),
          "<#{unquote(el)}#{unquote(compile_attrs(attrs))}>"
        )
      end
    end
  end

  defmacro text(text) do
    quote do
      put_buffer(var!(buff, Dsl.Html), to_string(unquote(text)))
    end
  end

  defmacro partial(text), do: quote(do: text(unquote(text)))

  defmacro deftag(name, do: block) do
    quote do
      defmacro unquote(name)(attrs \\ [])

      defmacro unquote(name)(attrs) do
        outer = unquote(Macro.escape(block))
        name = unquote(name)

        {inner, attrs} = Keyword.pop(attrs, :do, nil)

        inner =
          case inner do
            {_, _, inner} ->
              inner

            nil ->
              nil
          end

        quote do
          unquote(name)(unquote(attrs), unquote(inner))
        end
      end

      defmacro unquote(name)(attrs, inner) do
        outer = unquote(Macro.escape(block))
        name = unquote(name)

        {tag, meta, [old_attrs]} = outer

        attrs = [
          {:do, inner}
          | Keyword.merge(old_attrs, attrs, fn _, two, three -> two <> " " <> three end)
        ]

        outer = {tag, meta, [attrs]}

        quote do
          unquote(outer)
        end
      end
    end
  end

  defp compile_attrs([]), do: ""

  defp compile_attrs(attrs) do
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
