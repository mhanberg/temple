defmodule Temple.Component do
  @moduledoc """
  API for defining components.

  Component modules are basically normal Phoenix View modules. The contents of the `render` macro are compiled into a `render/2` function. This means that you can define functions in your component module and use them in your component markup.

  Since component modules are view modules, the assigns you pass to the component are accessible via the `@` macro and the `assigns` variable.

  You must `require Temple.Component` in your views that use components, as the `c` and `slot` generate markup that uses macros provided by Temple.

  ## Components

  ```elixir
  defmodule MyAppWeb.Components.Flash do
    import Temple.Component

    def border_class(:info), do: "border-blue-500"
    def border_class(:warning), do: "border-yellow-500"
    def border_class(:error), do: "border-red-500"
    def border_class(:success), do: "border-green-500"

    render do
      div class: "border rounded p-2 #\{assigns[:class]} #\{border_class(@message_type)}" do
        slot :default
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
  # lib/my_app_web/views/page_view.ex
  alias MyAppWeb.Components.Flex

  # lib/my_app_web/templates/page/index.html.exs
  c Flex, class: "justify-between items center" do
    for item <- items do
      div class: "p-4" do
        item.name
      end
    end
  end
  ```

  ## Slots

  Components can use slots, which are named placeholders for markup that can be passed to the component by the caller.

  Slots are invoked by using the `slot` keyword, followed by the name of the slot and any assigns you'd like to pass into the slot.

  `slot` is a _**compile time keyword**_, not a function or a macro, so you won't see it in the generated documention.

  ```elixir
  defmodule Flex do
    import Temple.Component

    render do
      div class: "flex #\{@class}" do
        slot :default
      end
    end
  end
  ```

  You can also use "named slots", which allow for data to be passed back into them. This is very useful
  when a component needs to pass data from the inside of the component back to the caller, like when rendering a form in LiveView.

  ```elixir
  defmodule Form do
    import Temple.Component

    render do
      form = form_for(@changeset, @action, assigns)

      form

      slot :f, form: form

      "</form>"
    end
  end
  ```

  By default, the body of a component fills the `:default` slot.

  Named slots can be defined by invoking the `slot` keyword with the name of the slot and a do block.

  You can also pattern match on any assigns that are being passed into the slot as if you were defining an anonymous function.

  `slot` is a _**compile time keyword**_, not a function or a macro, so you won't see it in the generated documention.

  ```elixir
  # lib/my_app_web/templates/post/new.html.lexs

  c Form, changeset: @changeset,
          action: @action,
          class: "form-control",
          phx_submit: :save,
          phx_change: :validate do
    slot :f, %{form: f} do
      label f do
        "Widget Name"
        text_input f, :name, class: "text-input"
      end

      submit "Save!"
    end
  end
  ```
  """

  @doc false
  defmacro __component__(module, assigns \\ [], block \\ []) do
    {inner_block, assigns} =
      case {block, assigns} do
        {[do: do_block], _} -> {rewrite_do(do_block), assigns}
        {_, [do: do_block]} -> {rewrite_do(do_block), []}
        {_, _} -> {nil, assigns}
      end

    if is_nil(inner_block) do
      quote do
        Phoenix.View.render(unquote(module), :self, unquote(assigns))
      end
    else
      quote do
        Phoenix.View.render(
          unquote(module),
          :self,
          Map.put(Map.new(unquote(assigns)), :inner_block, unquote(inner_block))
        )
      end
    end
  end

  @doc false
  defmacro __render_block__(inner_block, argument \\ []) do
    quote do
      unquote(inner_block).(unquote(argument))
    end
  end

  defp rewrite_do([{:->, meta, _} | _] = do_block) do
    {:fn, meta, do_block}
  end

  defp rewrite_do(do_block) do
    quote do
      fn _ ->
        unquote(do_block)
      end
    end
  end

  @doc """
  Defines a component template.

  ## Usage

  ```elixir
  defmodule MyAppWeb.Components.Flash do
    import Temple.Component

    def border_class(:info), do: "border-blue-500"
    def border_class(:warning), do: "border-yellow-500"
    def border_class(:error), do: "border-red-500"
    def border_class(:success), do: "border-green-500"

    render do
      div class: "border rounded p-2 #\{assigns[:class]} #\{border_class(@message_type)}" do
        slot :default
      end
    end
  end
  ```

  """
  defmacro render(block) do
    quote do
      def render(var!(assigns)) do
        require Temple

        _ = var!(assigns)

        Temple.compile(unquote(Temple.Component.__engine__()), unquote(block))
      end

      def render(:self, var!(assigns)) do
        require Temple

        _ = var!(assigns)

        Temple.compile(unquote(Temple.Component.__engine__()), unquote(block))
      end
    end
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
        slot :default
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
        import Temple.Component
        alias unquote(__CALLER__.module)

        render do
          unquote(block)
        end
      end
    end
  end

  @doc false
  def __engine__() do
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
