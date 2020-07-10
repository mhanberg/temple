defmodule Temple do
  alias Temple.Buffer

  @moduledoc """
  > Warning: Docs are WIP

  Temple syntax is available inside the `temple` and `live_temple` macros, and is compiled into EEx at build time.

  ### Usage

  ```elixir
  temple do
    # You can define attributes by passing a keyword list to the element, the values can be literals or variables.
    class = "text-blue"
    id = "jumbotron"

    div class: class, id: id do
      # Text nodes can be emitted as string literals or variables.
      "Bob"

      id
    end

    # if and unless expressions can be used to conditionally render content
    if 5 > 0 do
      p do
        "Greater than 0!"
      end
    end

    unless 5 > 0 do
      p do
        "Less than 0!"
      end
    end

    # You can loop over items using for comprehensions
    for x <- 0..5 do
      div do
        x
      end
    end

    # You can use multiline anonymous functions, like if you're building a form in Phoenix
    form_for @changeset, Routes.user_path(@conn, :create), fn f ->
      "Name: "
      text_input f, :name
    end

    # You can explicitly call a tag by prefixing with the Temple module
    Temple.div do
      "Foo"
    end

    # You can also pass children as a do key instead of a block
    div do: "Alice", class: "text-yellow"
  end
  ```

  ### Reserved keywords

  You can pass a keyword list to an element as element attributes, but there are several reserved keywords.

  #### Compact

  Passing `compact: true` will not rendering new lines from within the element. This is useful if you are trying to use the `:empty` psuedo selector.

  ```elixir
  temple do
    p compact: true do
      "Foo"
    end
    p do
      "Bar"
    end
  end
  ```

  would evaluate to

  ```html
  <p>Foo</p>
  <p>
  Bar
  </p>
  ```

  ### Configuration

  #### Aliases

  You can add an alias for an element if there is a namespace collision with a function. If you are using `Phoenix.HTML`, there will be namespace collisions with the `<link>` and `<label>` elements.

  ```elixir
  config :temple, :aliases,
    label: :_label,
    link: :_link

  temple do
    _label do
      "Email"
    end

    _link href: "/css/site.css"
  end
  ```

  This will result in:

  ```html
  <label>
    Email
  </label>

  <link href="/css/site.css">
  ```
  """

  defmacro __using__(_) do
    quote location: :keep do
      import Temple
    end
  end

  defmacro temple([do: block] = _block) do
    {:ok, buffer} = Buffer.start_link()

    buffer
    |> Temple.Parser.Private.traverse(block)

    markup = Buffer.get(buffer)

    Buffer.stop(buffer)

    quote location: :keep do
      unquote(markup)
    end
  end

  defmacro temple(block) do
    quote location: :keep do
      import Temple

      {:ok, buffer} = Buffer.start_link()

      buffer
      |> Temple.Parser.Private.traverse(unquote(block))

      markup = Buffer.get(buffer)

      Buffer.stop(buffer)

      markup
    end
  end

  defmacro live_temple([do: block] = _block) do
    {:ok, buffer} = Buffer.start_link()

    buffer
    |> Temple.Parser.Private.traverse(block)

    markup = Buffer.get(buffer)

    Buffer.stop(buffer)
    EEx.compile_string(markup, engine: Phoenix.LiveView.Engine)
  end
end
