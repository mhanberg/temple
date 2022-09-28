defmodule Temple do
  @engine Application.compile_env(:temple, :engine, EEx.SmartEngine)

  @moduledoc """
  Temple syntax is available inside the `temple`, and is compiled into efficient Elixir code at compile time using the configured `EEx.Engine`.

  You should checkout the [guides](https://hexdocs.pm/temple/your-first-template.html) for a more in depth explanation.

  ## Usage

  ```elixir
  defmodule MyApp.HomePage do
    import Temple

    def render() do
      assigns = %{title: "My Site | Sign Up", logged_in: false}

      temple do
        "<!DOCTYPE html>"

        html do
          head do
            meta charset: "utf-8"
            meta http_equiv: "X-UA-Compatible", content: "IE=edge"
            meta name: "viewport", content: "width=device-width, initial-scale=1.0"
            link rel: "stylesheet", href: "/css/app.css"

            title do: @title
          end

          body do
            header class: "header" do
              ul do
                li do
                  a href: "/", do: "Home"
                end
                li do
                  if @logged_in do
                    a href: "/logout", do: "Logout"
                  else
                    a href: "/login", do: "Login"
                  end
                end
              end
            end

            main do
              "Hi! Welcome to my website."
            end
          end
        end
      end
    end
  end
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
    label: :label_tag,
    link: :link_tag,
    select: :select_tag

  temple do
    label_tag do
      "Email"
    end

    link_tag href: "/css/site.css"
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
  @doc false
  def engine(), do: @engine

  defmacro temple(block) do
    opts = [engine: engine()]

    quote do
      require Temple.Renderer
      Temple.Renderer.compile(unquote(opts), unquote(block))
    end
  end

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
      message = "attempted to render slot <:#{entry.__slot__}> but the slot has no inner content"
      raise RuntimeError, message
    end

    entry.inner_block.(argument)
  end
end
