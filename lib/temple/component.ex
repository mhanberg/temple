defmodule Temple.Component do
  @moduledoc """
  API for defining components.

  Component modules are basically normal Phoenix View modules. The contents of the `render` macro are compiled into a `render/2` function. This means that you can define functions in your component module and use them in your component markup.

  Since component modules are view modules, the assigns you pass to the component are accessible via the `@` macro and the `assigns` variable.

  ## Usage

  ```elixir
  defmodule MyAppWeb.Components.Flash do
    use Temple.Component

    def border_class(:info), do: "border-blue-500"
    def border_class(:warning), do: "border-yellow-500"
    def border_class(:error), do: "border-red-500"
    def border_class(:success), do: "border-green-500"

    render do
      div class: "border rounded p-2 #\{assigns[:class]} #\{border_class(@message_type)}" do
        @inner_content
      end
    end
  end
  ```

  Components are used by calling the `c` keyword, followed by the component module and any assigns you need to pass to the template.

  `c` is a _**compile time keyword**_, not a function or a macro, so you won't see it in the generated documention.

  ```
  c MyAppWeb.Components.Flash, class: "font-bold", message_type: :info do
    ul do
      for info <- infos do
        li class: "p-4" do
          info.message
        end
      end
    end
  end
  ```

  Since components are just modules, if you alias your module, you can use them more ergonomically.

  ```
  alias MyAppWeb.Components.Flex

  c Flex, class: "justify-between items center" do
    for item <- items do
      div class: "p-4" do
        item.name
      end
    end
  end
  ```
  """

  defmacro __using__(_) do
    quote do
      import Temple.Component, only: [render: 1]
    end
  end

  @doc """
  Defines a component template.

  ## Usage

  ```elixir
  defmodule MyAppWeb.Components.Flash do
    use Temple.Component

    def border_class(:info), do: "border-blue-500"
    def border_class(:warning), do: "border-yellow-500"
    def border_class(:error), do: "border-red-500"
    def border_class(:success), do: "border-green-500"

    render do
      div class: "border rounded p-2 #\{assigns[:class]} #\{border_class(@message_type)}" do
        @inner_content
      end
    end
  end
  ```

  """
  defmacro render(block) do
    slots =
      Temple.compile(
        %{
          engine: Temple.Component.engine(),
          line: __CALLER__.line,
          file: __CALLER__.file
        },
        block
      )

    catchall =
      quote do
        def render(var!(assigns)) do
          render(:default, var!(assigns))
        end
      end

    render_funcs =
      for {name, %{assigns: assigns, slot: slot}} <- slots do
        quote do
          def render(unquote(name), var!(assigns)) do
            require Temple

            unquote(assigns) = var!(assigns)

            unquote(slot)
          end
        end
      end

    [catchall] ++ render_funcs
  end

  @doc """
  Defines a component module.

  This macro makes it easy to define components without creating a separate file. It literally inlines a component module.

  Since it defines a module inside of the current module, local function calls from the outer module won't be available. For convenience, the outer module is aliased for you, so you can call remote functions with a shorter module name.

  ## Usage

  ```elixir
  def MyAppWeb.SomeView do
    use MyAppWeb.SomeView, :view
    import Temple.Component, only: [defcomp: 2]

    # define a function in outer module
    def foobar(), do: "foobar"

    # define a component
    defcomp Button do
      button id: SomeView.foobar(), # `MyAppWeb.SomeView` is aliased for you.
             class: "text-sm px-3 py-2 rounded #\{assigns[:extra_classes]}",
             type: "submit" do
        @inner_content
      end
    end
  end

  # use the component in a SomeView template. Or else, you must alias `MyAppWeb.SomeView.Button`
  c Button, extra_classes: "border-2 border-red-500" do
    "Submit!"
  end
  ```
  """
  defmacro defcomp(module, [do: block] = _block) do
    quote location: :keep do
      defmodule unquote(module) do
        use Temple.Component
        alias unquote(__CALLER__.module)

        render do
          unquote(block)
        end
      end
    end
  end

  @doc false
  def engine() do
    cond do
      Code.ensure_loaded?(Phoenix.LiveView.Engine) ->
        Phoenix.LiveView.Engine

      Code.ensure_loaded?(Phoenix.HTML.Engine) ->
        Phoenix.HTML.Engine

      true ->
        nil
    end
  end
end
