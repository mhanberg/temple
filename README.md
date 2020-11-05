# ![](temple.png)

[![Actions Status](https://github.com/mhanberg/temple/workflows/CI/badge.svg)](https://github.com/mhanberg/temple/actions)
[![Hex.pm](https://img.shields.io/hexpm/v/temple.svg)](https://hex.pm/packages/temple)
[![Slack](https://img.shields.io/badge/chat-Slack-blue)](https://elixir-lang.slack.com/messages/CMH6MA4UD)

> You are looking at the README for the master branch. The README for the latest stable release is located [here](https://github.com/mhanberg/temple/tree/v0.5.0).

Temple is a DSL for writing HTML using Elixir.

You're probably here because you want to use Temple to write Phoenix templates, which is why Temple includes a [Phoenix template engine](#phoenix-templates).

## Installation

Add `temple` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:temple, "~> 0.6.0-alpha.4"}]
end
```

or

```elixir
def deps do
  [{:temple, github: "mhanberg/temple"}]
end
```

## Usage

Using Temple is a as simple as using the DSL inside of an `temple/1` block. This returns an EEx string at compile time.

See the [documentation](https://hexdocs.pm/temple/Temple.Html.html) for more details.

```elixir
use Temple

temple do
  h2 do: "todos"

  ul class: "list" do
    for item <- @items do
      li class: "item" do
        div class: "checkbox" do
          div class: "bullet hidden"
        end

        div do: item
      end
    end
  end

  script do: """
  function toggleCheck({currentTarget}) {
    currentTarget.children[0].children[0].classList.toggle("hidden");
  }

  let items = document.querySelectorAll("li");

  Array.from(items).forEach(checkbox => checkbox.addEventListener("click", toggleCheck));
  """
end
```

### Components

To define a component, you can define a module that that starts with your defined components prefix. The last name in the module should be a came-cases version of the component name.

This module should implement the `Temple.Component` behaviour.

```elixir
# config/config.exs

config :temple, :component_prefix, MyAppWeb.Components

# also set the path so recompiling will work in Phoenix projects
config :temple, :components_path, "./lib/my_app_web/components"
```

You can then use this component in any other temple template.

For example, if I were to define a `flex` component, I would create the following module.

```elixir
defmodule MyAppWeb.Components.Flex do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      div class: "flex #{@temple[:class]}", id: @id do
        @children
      end
    end
  end
end
```

And we could use the component like so

```elixir
flex class: "justify-between items-center", id: "arnold" do
  div do: "Hi"
  div do: "I'm"
  div do: "Arnold"
  div do: "Schwarzenegger"
end
```

We've demonstrated several features to components in this example.

We can pass assigns to our component, and access them just like we would in a normal phoenix template. If they don't match up with any assigns we passed to our component, they will be rendered as-is, and will become a normal Phoenix assign.

You can also access a special `@temple` assign. This allows you do optionally pass an assign, and not have the `@my_assign` pass through.  If you didn't pass it to your component, it will evaluate to nil.

The block passed to your component can be accessed as `@children`. This allows your components to wrap a body of markup from the call site.

In order for components to trigger a recompile when they are changed, you can call `use Temple.Recompiler` in your `lib/my_app_web.ex` file, in the `view`, `live_view`, and `live_component` functions

```elixir
def view do
  quote do
    # ...
    use Temple.Recompiler
    # ...
  end
end
```

### Phoenix templates

Add the templating engine to your Phoenix configuration.

```elixir
# config.exs
config :phoenix, :template_engines,
  exs: Temple.Engine
  # or for LiveView support
  # this will work for files named like `index.html.lexs`
  # you can enable Elixir syntax highlighting in your editor
  lexs: Temple.LiveViewEngine

# config/dev.exs
config :your_app, YourAppWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/myapp_web/(live|views)/.*(ex|exs|lexs)$",
      ~r"lib/myapp_web/templates/.*(eex|exs|lexs)$"
    ]
  ]
```

```elixir
# app.html.exs

html lang: "en" do
  head do
    meta charset: "utf-8"
    meta http_equiv: "X-UA-Compatible", content: "IE=edge"
    meta name: "viewport", content: "width=device-width, initial-scale=1.0"
    title do: "YourApp · Phoenix Framework"

    link rel: "stylesheet", href: Routes.static_path(@conn, "/css/app.css")
  end

  body do
    header do
      section class: "container" do
        nav role: "navigation" do
          ul do
            li do: a("Get Started", href: "https://hexdocs.pm/phoenix/overview.html")
          end
        end

        a href: "http://phoenixframework.org/", class: "phx-logo" do
          img src: Routes.static_path(@conn, "/images/phoenix.png"),
              alt: "Phoenix Framework Logo"
        end
      end
    end

    main role: "main", class: "container" do
      p class: "alert alert-info", role: "alert", compact: true, do: get_flash(@conn, :info)
      p class: "alert alert-danger", role: "alert", compact: true, do: get_flash(@conn, :error)

      render @view_module, @view_template, assigns
    end

    script type: "text/javascript", src: Routes.static_path(@conn, "/js/app.js")
  end
end
```

### Tasks

#### temple.gen.layout

Generates the app layout.

#### temple.gen.html

Generates the templates for a resource.

### Formatter

To include Temple's formatter configuration, add `:temple` to your `.formatter.exs`.

```elixir
[
  import_deps: [:temple],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,lexs}"],
]
```
