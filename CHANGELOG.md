# CHANGELOG

## Main

### Enhancements

- [breaking] Attributes who values are boolean expressions will be emitted as boolean attributes.
- Class "object" syntax. Conditionally add classes by passing a keyword list to the `class` attribute.

## 0.6.2

### Bug fixes

- Compile void elements with zero attrs #135

## 0.6.1

### Bug fixes

- Only collect slots in the root of a component instance #127

## 0.6.0 The LiveView compatibility release!

Temple now is written to be fully compatible with Phoenix LiveView! This comes with substantial internal changes as well as a better component API.

### Phoenix LiveView

Temple now outputs LiveView compatible EEx at compile time, which is fed right into the normal LiveView EEx engine (or the traditional HTML Engine if you are not using LiveView).

### Components

Temple now has a more complete component API.

Components work with anywhere, whether you are writing a little plug app, a vanilla Phoenix app, or a Phoenix LiveView app!

Please see the [documenation](https://hexdocs.pm/temple/Temple.html) for more information.

To migrate component from the 0.5.0 syntax to the 0.6.0 syntax, you can use the following as a guide

```elixir
# 0.5.0

# definition
defmodule PageView do
  defcomponent :flex do
    div id: @id, class: "flex" do
      @children
    end
  end
end

# usage

require PageView
# or 

import PageView

temple do
  PageView.flex id: "my-flex" do
    div "Item 1"
    div "Item 2"
    div "Item 3"
  end

  # with import
  flex id: "my-flex" do
    div "Item 1"
    div "Item 2"
    div "Item 3"
  end
end
```

to

```elixir
# 0.6.0

# definition

defmodule Flex do
  import Temple.Component

  render do
    div id: @id, class: "flex" do
      slot :default
    end
  end
end

# usage

temple do
  c Flex id: "my-flex" do
    div do: "Item 1"
    div do: "Item 2"
    div do: "Item 3"
  end
end
```

### Other breaking changes

0.6.0 has been a year in the making and a lot has changed in that time (in many cases, several times over), and I honestly can't really remember everything that is different now, but I will list some things here that I think you'll need to change or look out for.

- The `partial` macro is removed.
    - You can now just call the `render` function like you normally would to render a phoenix partial.
- The `defcomponent` macro is removed.
    - You now define components using the API described above.
- The `text` macro is now removed.
    - You can just use a string literal or a variable to emit a text node.
- Elements and components no longer can take "content" as the first argument. A do block is now required, but you can still use the keyword list style for a concise style, e.g., `span do: "foobar"` instead of `span "foobar"`.
- The `:compact` reserved keyword option was removed.
- The macros that wrapped `Phoenix.HTML` are removed as they are no longer needed.
- The `temple.convert` task has been removed, but I am working to bring it back.

There might be some more, so if you run into any problems, please open a [GitHub Discussion](https://github.com/mhanberg/temple/discussions/new).

## 0.6.0-rc.1

### Enhancements

- Components can now use slots.
- Markup is 100% live view compliant.

### Breaking

- `@inner_content` is removed in favor of invoking the default slot.
- The `compact` reserved keyword for elements has been removed. This is not really intentional, just a side effect of getting slots to a usable place. I expect to add it back, or at least similar functionality in the future.

## 0.6.0-rc.0

- Can pass a keyword list to be evaluated at runtime as attrs/assigns to an element.

```elixir
# compile time

div class: "foo", id: bar do
  # something
end

# <div class="foo" id="<%= bar %>">
#   <!-- something -->
# </div>

# runtime

div some_var do
  # something
end

# <div<%= UtilsTempleModule.runtime_attrs(some_var) %>>
#   <!-- something -->
# </div>
```

- it now parses `case` expressions

### Breaking

#### Components

Components are now a thin layer over template partials, compiling to calls to `render/3` and `render_layout/4` under the hood.

To upgrade your components the new syntax, you can copy your component markup and paste it into the `render/1` macro inside the component module and references to `@children` can be updated to `@inner_content`.

Components can are also referenced differently than before when using them. Before, one would simply call `flex` to render a component named `Flex`. Now, one must use the keyword `c` to render a component, passing the keyword the component module along with any assigns.

##### Before

```elixir
# definition
div class: "flex #{@class}" do
  @children
end

# usage

flex class: "justify-between" do
  for item <- @items do
    div do
      item.name
    end
  end
end
```

##### After

```elixir
# definition
defmodule MyAppWeb.Component.Flex do
  use Temple.Component

  render do
    div class: "flex #{@class}" do
      @inner_content
    end
  end
end

# usage
alias MyApp.Component.Flex # probably located in my_app_web.ex

c Flex, class: "justify-between" do
  for item <- @items do
    div do
      item.name
    end
  end
end
```

### Bugs

- Did not correctly parse expressions with do blocks where the expression had two or more arguments before the block

## 0.6.0-alpha.4

- Fix a bug where lists would not properly compile

## 0.6.0-alpha.3

- Compile functions/macros that take blocks that are not if/unless/for

## 0.6.0-alpha.2

### Component API

Please see the README for more details regarding the Component API

## 0.6.0-alpha.1

### Generators

You can now use `mix temple.gen.live Context Schema table_name col:type` in the same way you can with Phoenix.

### Other

- Make a note in the README to set the filetype for Live temple templates to `lexs`. You should be able to set this extension to use Elixir for syntax highlighting in your editor. In vim, you can add the following to your `.vimrc`

```vim
augroup elixir
  autocmd!

  autocmd BufRead,BufNewFile *.lexs set filetype=elixir
augroup END
```

## 0.6.0-alpha.0

### Breaking!

This version is the start of a complete rewrite of Temple.

- Compiles to EEx at build time.
- Compatible with `Phoenix.LiveView`
- All modules other than `Temple` are removed
- `mix temple.convert` Mix task removed

## 0.5.0

- Introduce `@assigns` assign
- Join markup with a newline instead of empty string

## 0.4.4

- Removes unnecessary plug dependency.
- Bumps some other dependencies.

## 0.4.3

- Compiles when Phoenix is not included in the host application.

## 0.4.2

- temple.convert task no longer fails when parsing HTML fragments.

## 0.4.1

- Only use Floki in dev and test environments

## 0.4.0

- `Temple.Svg` module
- `mix temple.convert` Mix task
- (dev) rename `mix update_mdn_docs` to `mix temple.update_mdn_docs` and don't ship it to hex

### Breaking

- Rename `Temple.Tags` to `Temple.Html`

## v0.3.1

- `Temple.Form.phx_label`, `Temple.Form.submit`, `Temple.Link.phx_button`, `Temple.Link.phx_link` now correctly parse blocks. Before this, they would escape anything passed to the block instead of accepting it as raw HTML.

## v0.3.0

- `Temple.Tags.html` now prepends the doctype, making it valid HTML
- `Temple.Elements` module

### Breaking

- `Temple.Tags.html` no longer accepts content as the first argument. A legal `html` tag must contain only a single `head` and a single `body`.

## 0.2.0

- Wrap `radio_buttton/4` from Phoenix.HTML.Form

## 0.1.2

### Bugfixes

- Allow components to be used correctly when their module was `require`d instead of `import`ed

## 0.1.1

### Bugfixes

- Escape content passed to 1-arity tag macros

### Development

- Upgrade various optional development packages

## 0.1.0

- Initial Release
