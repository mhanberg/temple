# Getting Started

## Install

Welcome!

Temple is a HTML DSL for Elixir, let's get started!


First, make sure you are using Elixir `V1.13` or higher.

Add `:temple` to your deps and run `mix deps.get`

```elixir
{:temple, "~> 0.14.0"}
```

Now you must prepend the Temple compiler to your projects `:compilers` configuration in `mix.exs`. There is a chance that your project doesn't set this option at all, but don't worry, it's really easy to add!

```elixir
defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      # ...
      compilers: [:temple] ++ Mix.compilers(),
      # ...
    ]
  end

# ...

end
```

All done, Now let's start building our app!

## Configuration

Temple works out of the box without any configuration, but here are a couple of conifg options that you could need to use.

### Engine

By default, Temple uses the built in `Phoenix.HTML.Engine`. If you want to use a different engine, this is as easy as setting the `:engine` configuration option.

You can also configure the function that is used for runtime attributes. By default, Temple uses `Phoenix.HTML.attributes_escape/1`.

```elixir
# config/config.exs

config :temple,
  engine: EEx.SmartEngine,
  attributes: {Temple, :attributes}
```

### Aliases

Temple code will reserve some local function calls for HTML tags. If you have a local function that you would like to use instead, you can create an alias for any tag.

Common aliases for Phoenix projects look like this:

```elixir
config :temple,
  aliases: [
    label: :label_tag,
    link: :link_tag,
    select: :select_tag,
    textarea: :textarea_tag
  ]
```
