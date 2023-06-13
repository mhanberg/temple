defmodule Temple.Component do
  @moduledoc """
  Use this module to create your own component implementation.

  This is only required if you are not using a component implementation from another framework,
  like Phoenix LiveView.

  At it's core, a component implmentation includes the following functions

  - `component/2`
  - `inner_block/2`
  - `render_slot/2`

  These functions are used by the template compiler, so you won't be calling them directly.

  ## Usage

  Invoke the `__using__/1` macro to create your own module, and then import that module where you
  need to define define or use components (usually everywhere).

  We'll use an example that is similar to what Temple uses in its own test suite..

  ```elixir
  defmodule MyAppWeb.Component do
    use Temple.Component

    defmacro __using__(_) do
      quote do
        import Temple
        import unquote(__MODULE__)
      end
    end
  end
  ```

  Then you can `use` your module when you want to define or use a component.

  ```elixir
  defmodule MyAppWeb.Components do
    use MyAppWeb.Component

    def basic_component(_assigns) do
      temple do
        div do
          "I am a basic component"
        end
      end
    end
  end
  ```

  """
  defmacro __using__(_) do
    quote do
      import Temple
      @doc false
      def component(func, assigns, _) do
        apply(func, [assigns])
      end

      defmacro inner_block(_name, do: do_block) do
        __inner_block__(do_block)
      end

      @doc false
      def __inner_block__([{:->, meta, _} | _] = do_block) do
        inner_fun = {:fn, meta, do_block}

        quote do
          fn arg ->
            _ = var!(assigns)
            unquote(inner_fun).(arg)
          end
        end
      end

      def __inner_block__(do_block) do
        quote do
          fn arg ->
            _ = var!(assigns)
            unquote(do_block)
          end
        end
      end

      defmacro render_slot(slot, arg) do
        quote do
          unquote(__MODULE__).__render_slot__(unquote(slot), unquote(arg))
        end
      end

      @doc false
      def __render_slot__([], _), do: nil

      def __render_slot__([entry], argument) do
        call_inner_block!(entry, argument)
      end

      def __render_slot__(entries, argument) when is_list(entries) do
        assigns = %{}
        _ = assigns

        temple do
          for entry <- entries do
            call_inner_block!(entry, argument)
          end
        end
      end

      def __render_slot__(entry, argument) when is_map(entry) do
        entry.inner_block.(argument)
      end

      defp call_inner_block!(entry, argument) do
        if !entry.inner_block do
          message = "attempted to render slot #{entry.__slot__} but the slot has no inner content"
          raise RuntimeError, message
        end

        entry.inner_block.(argument)
      end
    end
  end
end
