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

The default slot can be rendered from within your component by passing the `slot` the atom `:default`. Let's redefine our button component using slots.

```elixir
defmodule MyApp.Components do
  import Temple

  def button(assigns) do
    temple do
      button type: "button", class: "bg-blue-800 text-white rounded #{@class}" do
        slot :default
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
            slot :header
          end
        end

        div class: "card-content" do
          div class: "content" do
            slot :default
          end
        end

        footer class: "card-footer", style: "background-color: #f5f5f5" do
          slot :footer
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
          a href="#", class: "card-footer-item", do: "Footer Item 1"
          a href="#", class: "card-footer-item", do: "Footer Item 2"
        end
      end
    end
  end
end
```

## Passing Data Through Slots

Sometimes it is necessary to pass data from a component definition back to the call site.

Let's look at what a `table` component could look like.

#### Definition

```elixir
defmodule MyApp.Components do
  import Temple

  def cols(items) do
    items
    |> List.first()
    |> Map.keys()
    |> Enum.sort()
  end

  def table(assigns) do
    temple do
      table do
        thead do
          tr do
            for col <- cols(@entries) do
              tr do: String.upcase(to_string(col))
            end
          end
        end

        tbody do
          for row <- @entries do
            tr do
              for col <- cols(@entries) do
                td do
                  slot :cell, %{value: row[cell]}
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

When we render the slot, we can pattern match on the data passed through the slot. If this seems familiar, it's because this is the same syntax you use when writing your tests using `ExUnit.Case.test/3`.

```elixir
def MyApp.TableExample do
  import Temple
  import MyApp.Componens

  def render(assigns) do
    temple do
      section do
        h2 do: "Inventory Levels"

        c &table/1, entries: @item_inventories do
          slot :cell, %{value: value} do
            case value do
              0 ->
                span class: "font-bold" do
                  "Out of stock!"
                end

              level when is_number(level) ->
                span do
                  "#{level} in stock"
                end

              _ ->
                span do: value
            end
          end
        end
      end
    end
  end
end
```
