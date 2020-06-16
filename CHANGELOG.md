# Changelog

## Master

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
