# Components

Temple has the concept of components, which allow you an expressive and composable way to break up your templates into re-usable chunks.

A component is any arity-1 function that take an argument called `assigns` and returns the result of the `Temple.temple/1` macro.

## Definition

Here is an example of a simple Temple component. You can observe that it seems very similar to a regular Temple template, and that is because it is a regular template!

```elixir
defmodule MyApp.Components do
  import Temple

  def button(assigns) do
    temple do
      button type: "button", class: "bg-blue-800 text-white rounded #{@class}" do
        @text
      end
    end
  end
end
```

## Usage

To use a component, you will use the special `c` keyword. This is called a "keyword" because it is not a function or macro, but only exists inside of the `Temple.temple/1` block.

The first argument will be the function reference to your component function, followed by any assigns.

```elixir
defmodule MyApp.ConfirmDialog do
  import Temple
  import MyApp.Components

  def render(assigns) do
    temple do
      dialog open: true do
        p do: "Are you sure?"
        form method: "dialog" do
          c &button/1, class: "border border-white", text: "Yes"
        end
      end
    end
  end
end
```

## Slots

Temple components can take "slots" as well. This is the method for providing dynamic content from the call site into the component.

Slots are defined and rendered using the `slot` keyword. This is similar to the `c` keyword, in that it is not defined using a function or macro.

### Default Slot

The default slot can be rendered from within your component by passing the `slot` the `@inner_block` assign. Let's redefine our button component using slots.

```elixir
defmodule MyApp.Components do
  import Temple

  def button(assigns) do
    temple do
      button type: "button", class: "bg-blue-800 text-white rounded #{@class}" do
        slot @inner_block
      end
    end
  end
end
```

You can pass content through the "default" slot of your component simply by passing a `do/end` block to your component at the call site. This is a special case for the default slot.

```elixir
defmodule MyApp.ConfirmDialog do
  import Temple
  import MyApp.Components

  def render(assigns) do
    temple do
      dialog open: true do
        p do: "Are you sure?"
        form method: "dialog" do
          c &button/1, class: "border border-white" do
            "Yes"
          end
        end
      end
    end
  end
end
```

### Named Slots

You can also define a "named" slot, which allows you to pass more than one set of dynamic content to your component.

We'll use a "card" example to illustrate this. This example is adapted from the [Surface documentation](https://surface-ui.org/slots) on slots.

#### Definition

```elixir
defmodule MyApp.Components do
  import Temple

  def card(assigns) do
    temple do
      div class: "card" do
        header class: "card-header", style: "background-color: @f5f5f5" do
          p class: "card-header-title" do
            slot @header
          end
        end

        div class: "card-content" do
          div class: "content" do
            slot @inner_block
          end
        end

        footer class: "card-footer", style: "background-color: #f5f5f5" do
          slot @footer
        end
      end
    end
  end
end
```

#### Usage

```elixir
def MyApp.CardExample do
  import Temple
  import MyApp.Components

  def render(assigns) do
    temple do
      c &card/1 do
        slot :header do
          "A simple card component"
        end

        "This example demonstrates how to create components with multiple, named slots"

        slot :footer do
          a href: "#", class: "card-footer-item", do: "Footer Item 1"
          a href: "#", class: "card-footer-item", do: "Footer Item 2"
        end
      end
    end
  end
end
```

## Passing data to and through Slots

Sometimes it is necessary to pass data _into_ a slot (hereby known as *slot attributes*) from the call site and _from_ a component definition (hereby known as *slot arguments*) back to the call site.

Let's look at what a `table` component could look like. Here we observe we access an attribute in the slot in the header with `col.label`.

This example is taken from the HEEx documentation to demonstrate how you can build the same thing with Temple.

Note: Slot attributes can only be accessed on an individual slot, so if you define a single slot definition, you still need to loop through it to access it, as they are stored as a list.

#### Definition

```elixir
defmodule MyApp.Components do
  import Temple

  def table(assigns) do
    temple do
      table do
        thead do
          tr do
            for col <- @col do
              th do: col.label # 👈 accessing a slot attribute
            end
          end
        end

        tbody do
          for row <- @rows do
            tr do
              for col <- @col do
                td do
                  slot col, row
                end
              end
            end
          end
        end
      end
    end
  end
end
```

#### Usage

When we render the slot, we can pattern match on the data passed through the slot via the `:let` attribute.

```elixir
def MyApp.TableExample do
  import Temple
  import MyApp.Componens

  def render(assigns) do
    temple do
      section do
        h2 do: "Users"

        c &table/1, rows: @users do
          #          👇 defining the parameter for the slot argument
          slot :col, let: user, label: "Name" do # 👈 passing a slot attribute
            user.name
          end

          slot :col, let: user, label: "Address" do
            user.address
          end
        end
      end
    end
  end
end
```
