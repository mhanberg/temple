defmodule Temple do
  @engine Application.compile_env(:temple, :engine, EEx.SmartEngine)

  @moduledoc """
  Temple syntax is available inside the `temple`, and is compiled into EEx at build time.

  ## Usage

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

    # Attributes that result in boolean values will be emitted as a boolean attribute. Examples of boolean attributes are `disabled` and `checked`.

    input type: "text", disabled: true
    # <input type="text" disabled>

    input type: "text", disabled: false
    # <input type="text">

    # The class attribute also can take a keyword list of classes to conditionally render, based on the boolean result of the value.

    div class: ["text-red-500": false, "text-green-500": true] do
      "Alert!"
    end

    # <div class="text-green-500">Alert!</div>

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

    # You can explicitly emit a tag by prefixing with the Temple module
    Temple.div do
      "Foo"
    end

    # You can also pass children as a do key instead of a block
    div do: "Alice", class: "text-yellow"
  end
  ```

  ## Whitespace Control

  By default, Temple will emit internal whitespace into tags, something like this.

  ```elixir
  span do
    "Hello, world!"
  end
  ```

  ```html
  <span>
    Hello, world!
  </span>
  ```

  If you need to create a "tight" tag, you can use the keyword list style invocation of the `do` block.

  ```elixir
  span do: "Hello, world!"
  ```

  ```html
  <span>Hello, world!</span>
  ```

  ## Configuration

  ### Engine

  By default Temple wil use the `EEx.SmartEngine`, but you can configure it to use any other engine. Examples could be `Phoenix.HTML.Engine` or `Phoenix.LiveView.Engine`.

  ```elixir
  config :temple, engine: Phoenix.HTML.Engine
  ```

  ### Aliases

  You can add an alias for an element if there is a namespace collision with a function. If you are using `Phoenix.HTML`, there will be namespace collisions with the `<link>` and `<label>` elements.

  ```elixir
  config :temple, :aliases,
    label: :_label,
    link: :_link,
    select: :_select

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

  @doc """
  Context for temple markup.

  Returns an EEx string that can be passed into an EEx template engine.

  ## Usage

  ```elixir
  import Temple

  temple do
    div class: @class do
      "Hello, world!"
    end
  end

  # <div class="<%= @class %>">
  #   Hello, world!
  # </div>
  ```
  """

  defmacro temple(block) do
    opts = [engine: engine()]

    quote do
      require Temple.Renderer
      Temple.Renderer.compile(unquote(opts), unquote(block))
    end
  end

  @doc false
  def component(func, assigns) do
    apply(func, [assigns])
  end

  @doc false
  def engine(), do: @engine
end
