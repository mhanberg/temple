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
