# ![](temple.png)

[![Build Status](https://travis-ci.com/mhanberg/temple.svg?branch=master)](https://travis-ci.com/mhanberg/temple)
[![Hex.pm](https://img.shields.io/hexpm/v/temple.svg)](https://hex.pm/packages/temple)

Temple is a DSL for writing HTML using Elixir.

You're probably here because you want to use Temple to write Phoenix templates, which is why Temple includes a [Phoenix template engine](#phoenix-templates) and Temple-compatible [Phoenix form helpers](#phoenixhtml).

## Installation

Add `temple` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:temple, "~> 0.1.0"}]
end
```

## Usage

Using Temple is a as simple as using the DSL inside of an `htm/1` block. This returns a safe result of the form `{:safe, html_string}`.

See the [documentation](https://hexdocs.pm/temple/0.1.0/Temple.Tags.html) for more details.

```elixir
use Temple

htm do
  h2 "todos"

  ul class: "list" do
    for item <- @items do
      li class: "item" do
        div class: "checkbox" do
          div class: "bullet hidden"
        end

        div item
      end
    end
  end

  script """
  function toggleCheck({currentTarget}) {
    currentTarget.children[0].children[0].classList.toggle("hidden");
  }

  let items = document.querySelectorAll("li");

  Array.from(items).forEach(checkbox => checkbox.addEventListener("click", toggleCheck));
  """
end
```

### Components

Temple provides an API for creating custom components that act as custom HTML elements.

These components can be given `props` that are available inside the component definition as module attributes. The contents of a components `do` block are available as a special `@children` attribute.

See the [documentation](https://hexdocs.pm/temple/0.1.0/Temple.html#defcomponent/2) for more details.

```elixir
defcomponent :flex do
  div id: @id, class: "flex" do
    @children
  end
end

htm do
  flex id: "my-flex" do
    div "Item 1"
    div "Item 2"
    div "Item 3"
  end
end
```

### Phoenix.HTML

Temple provides macros for working with the helpers provided by the [Phoenix.HTML](https://www.github.com/phoenixframework/phoenix_html) package.

Most of the macros are purely wrappers, while the semantics of some are changed to work with Temple.

See the [documentation](https://hexdocs.pm/temple/0.1.0/Temple.Form.html#content) for more details.

```elixir
htm do
  form_for @conn, Routes.some_path(@conn, :create) do
    text_input form, :name
  end
end
```

### Phoenix templates

Add the templating engine to your Phoenix configuration.

See the [documentation](https://hexdocs.pm/temple/0.1.0/Temple.Engine.html#content) for more details.

```elixir
# config.exs
config :phoenix, :template_engines, exs: Temple.Engine

# your_app_web.ex
def view do
  quote do
    # ...
    use Temple # Replaces the call to import Phoenix.HTML
  end
end
```

```elixir
# app.html.exs
html lang: "en" do
  head do
    meta charset: "utf-8"
    meta http_equiv: "X-UA-Compatible", content: "IE=edge"
    meta name: "viewport", content: "width=device-width, initial-scale=1.0"
    title "YourApp · Phoenix Framework"

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
      p get_flash(@conn, :info), class: "alert alert-info", role: "alert"
      p get_flash(@conn, :error), class: "alert alert-danger", role: "alert"

      partial render(@view_module, @view_template, assigns)
    end

    script type: "text/javascript", src: Routes.static_path(@conn, "/js/app.js")
  end
end
```

### Formatter

Add the following to your `.formatter.exs` to unsure that the Temple DSL functions are formatted without parens.


```elixir
temple_funcs = ~w[
  html htm
  head title style script
  noscript template
  body section nav article aside h1 h2 h3 h4 h5 h6
  header footer address main
  p pre blockquote ol ul li dl dt dd figure figcaption div
  a em strong small s cite q dfn abbr data time code var samp kbd
  sub sup i b u mark ruby rt rp bdi bdo span
  ins del
  iframe object video audio canvas
  map svg math
  table caption colgroup tbody thead tfoot tr td th
  form fieldset legend label button select datalist optgroup
  option textarea output progress meter
  details summary menuitem menu
  meta link base
  area br col embed hr img input keygen param source track wbr
  text partial

  form_for inputs_for
  checkbox color_input checkbox color_input date_input date_select datetime_local_input
  datetime_select email_input file_input hidden_input number_input password_input range_input
  search_input telephone_input textarea text_input time_input time_select url_input
  reset submit phx_label multiple_select select phx_link phx_button
]a |> Enum.map(fn e -> {e, :*} end)

[
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: temple_funcs
]
```
