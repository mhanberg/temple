# ![](temple.png)

[![Actions Status](https://github.com/mhanberg/temple/workflows/CI/badge.svg)](https://github.com/mhanberg/temple/actions)
[![Hex.pm](https://img.shields.io/hexpm/v/temple.svg)](https://hex.pm/packages/temple)

> You are looking at the README for the main branch. The README for the latest stable release is located [here](https://github.com/mhanberg/temple/tree/v0.5.0).

Temple is a DSL for writing HTML and EEx using Elixir.

You're probably here because you want to use Temple to write Phoenix templates, which is why Temple includes a [Phoenix template engine](#phoenix-templates).

## Installation

Add `temple` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:temple, "~> 0.6.0-rc.0"},
    {:phoenix, ">= 1.5.0"} # requires at least Phoenix v1.5.0
  ]
end
```

or

```elixir
def deps do
  [{:temple, github: "mhanberg/temple"}]
end
```

## Goals

Currently Temple has the following things on which it won't compromise.

- Will only work with valid Elixir syntax.

## Usage

Using Temple is as simple as using the DSL inside of an `temple/1` block. This returns an EEx string at compile time.

See the [documentation](https://hexdocs.pm/temple/Temple.html) for more details.

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

Temple components are mostly a little syntax sugar over Phoenix's `render/3` and `render_layout/4` functions.

For example, if I were to define a `Flex` component, I would create the following module.

```elixir
defmodule MyAppWeb.Components.Flex do
  use Temple.Component

  render do
    div class: "flex #\{@class}" do
      @inner_content
    end
  end
end
```

And we could use the component like so

```elixir
# lib/my_app_web/views/page_view.ex
alias MyAppWeb.Components.Flex

# lib/my_app_web/templates/page/index.html.exs
c Flex, class: "justify-between items-center", id: "arnold" do
  div do: "Hi"
  div do: "I'm"
  div do: "Arnold"
  div do: "Schwarzenegger"
end
```

Please see the [discussion thread](https://github.com/mhanberg/temple/discussions/104) to share ideas and ask questions about the Component API 😄.

### Phoenix templates

Add the template engine to your Phoenix configuration.

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
