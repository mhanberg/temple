defmodule Temple do
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

  By default Temple wil use the `Phoenix.HTML.Engine`, but you can configure it to use any other engine. Examples could be `EEx.SmartEngine` or `Phoenix.LiveView.Engine`.

  ```elixir
  config :temple, engine: EEx.SmartEngine
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
  defmacro temple(block) do
    quote do
      require Temple.Renderer

      Temple.Renderer.compile(unquote(block))
    end
  end

  @doc false
  defdelegate engine, to: Temple.Renderer

  @doc """
  Compiles runtime attributes.

  To use this function, you set it in application config.

  By default, Temple uses `{Phoenix.HTML, :attributes_escape}`. This is useful if you want to use `EEx.SmartEngine`.

  ```elixir
  config :temple,
    engine: EEx.SmartEngine,
    attributes: {Temple, :attributes}
  ```

  > #### Note {: .info}
  >
  > This function does not do any HTML escaping

  > #### Note {: .info}
  >
  > This function is used by the compiler and shouldn't need to be used directly.
  """
  def attributes(attributes) do
    for {key, value} <- attributes, into: "" do
      case value do
        true -> ~s| #{key}|
        false -> ""
        value -> ~s| #{key}="#{value}"|
      end
    end
  end
end
