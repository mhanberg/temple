# Your First Template

A Temple template is written inside of the `Temple.temple/1` macro. Code inside there will be compiled into efficient Elixir code by the configured EEx engine. 

Local functions that have a corresponding HTML5 tag are reserved and will be used when generated your markup. Let's take a look at a basic form written with Temple.

```elixir
defmodule MyApp.FormExample do
  import Temple

  def form_page() do
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
          if @logged_in do
            header class: "header" do
              ul do
                li do
                  a href: "/", do: "Home"
                end
                li do
                  a href: "/logout", do: "Logout"
                end
              end
            end
          end

          form action: "", method: "get", class: "form-example" do
            div class: "form-example" do
              label for: "name", do: "Enter your name:"
              input type: "text", name: "name", id: "name", required: true
            end
            div class: "form-example" do
              label for: "email", do: "Enter your email:"
              input type: "email", name: "email", id: "email", required: true
            end
            div class: "form-example" do
              input type: "submit", value: "Subscribe!"
            end
          end
        end
      end
    end
  end
end
```

This example showcases an entire HTML page made with Temple! Let's dive a little deeper everything we're seeing here.

Through out this guide, you will see code that includes features that are explained later on. Feel free to skip ahead to read on, or just keep reading. It will all make sense eventually!

## Text Nodes

The text node is a basic building block of any HTML document. In Temple, text nodes are represented by Elixir string literals.

The very first line of the previous example is our doc type, emitted into the final document with `"<!DOCTYPE html>"`. This is a text node and will be emitted into the document as-is.

Note: String _literals_ are emitted into text nodes. If you are using string interpolation with the `#{some_expression}` syntax, that is treated as an expression and will be evaluated in whichever way the configured engine evaluates expression. By default, the `EEx.SmartEngine` doesn't do any escaping of expressions, so that could still be emitted as-is, or even as HTML to be interpreted by your web browser.

## Void Tags

Void tags are HTML5 tags that do not have children, meaning they are "self closing".

We can observe these in the previous example as the `<input>` tag. You'll note that the tag does not have a `:do` key or a `do` block.

## Non-void Tags

Non-void tags are HTML5 tags that _do_ have children. You are probably most familiar with these type of tags, as they include the famous `<div></div>` and `<span></span>`.

These tags can enclose their children nodes with either a `do/end` block or the inline `:do` keyword.

### Whitespace

Nonvoid tags that use the `do/end` syntax will be emitted _with_ internal whitespace.

```elixir
temple do
  div class: "foo" do
    # children
  end
end
```

...will emit markup that looks like...

```html
<div class="foo">
  <!-- children -->
</div>
```

Note: The Elixir comment _will not_ be rendered into an HTML comment. This is just used in the example. (This does sound like a good feature though...)

Nonvoid tags that use the `:do` keyword syntax will be emitted _without_ internal whitespace. This allows you to correctly use the `:empty` CSS psuedo-selector in your stylesheet. 


```elixir
temple do
  p class: "alert alert-info", do: "Your account was recently updated!"
end
```

...will emit markup that looks like...

```html
<p class="alert alert-info">Your account was recently updated!</p>
```

## Attributes

Temple leverages `Phoenix.HTML.attributes_escape/1` internally, so you can refer to it's documentation for all of the details.

## Elixir Expressions

Any Elixir expression can be used anywhere inside of a Temple template. Here are a few examples.

```elixir
temple do
  h2 do: "Members"

  ul do
    for member <- @members do
      li do: member
    end
  end
end
```

### Match Expressions

Match expression are handled slightly differently. Generally if you are assigning an expression to a variable (a match), you are going to use that binding later and do _not_ want to emit it into the document.

So, match expressions are _not_ emitted into the document. They are functionally equivalent to the `<% .. %.` syntax of `EEx`. The expression is evaluated, but not included in the rendered document.

Typically you should not be writing this type of expression inside of your template, but if you wanted to declare an alias, you would need to write the following to not emit the alias into the document.

```elixir
temple do
  _ = alias My.Deep.Module

  div do
    Module.func()
  end
end
```

## Assigns

Since Temple uses the `EEx.SmartEngine` by default, you are able to use the assigns feature.

The assigns feature allows you to ergonomically access the members of a `assigns` variable by the `@` macro.

The assign variable just needs to exist within the scope of the template (the same as a normal `EEx` template that uses `EEx.SmartEngine`), it can be a function parameter or created inside the function.

```elixir
def card(assigns) do
  temple do
    div class: "card" do
      section class: "card-header" do
        @name
      end

      section class: "card-body" do
        @bio
      end

      if Enum.any?(@socials) do
        section class: "card-footer" do
          for social <- @socials do
            a href: social.link do
              social.name
            end
          end
        end
      end
    end
  end
end
```
