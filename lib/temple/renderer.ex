defmodule Temple.Renderer do
  alias Temple.Parser.ElementList
  alias Temple.Parser.Text
  alias Temple.Parser.Components
  alias Temple.Parser.Slot
  alias Temple.Parser.NonvoidElementsAliases
  alias Temple.Parser.VoidElementsAliases
  alias Temple.Parser.AnonymousFunctions
  alias Temple.Parser.RightArrow
  alias Temple.Parser.DoExpressions
  alias Temple.Parser.Match
  alias Temple.Parser.Default

  alias Temple.Parser.Utils

  @default_engine EEx.SmartEngine

  alias Temple.Parser

  defmacro compile(do: block) do
    block
    |> Parser.parse()
    |> Temple.Renderer.render()
  end

  def render(asts, opts \\ [])

  def render(asts, opts) when is_list(asts) and is_list(opts) do
    engine = Keyword.get(opts, :engine, @default_engine)

    state = %{
      engine: engine,
      indentation: 0,
      terminal_node: false
    }

    buffer = engine.init(%{})

    buffer =
      for ast <- asts, reduce: buffer do
        buffer ->
          render(buffer, state, ast)
      end

    engine.handle_body(buffer)
  end

  def render(buffer, state, %Text{text: text}) do
    state.engine.handle_text(
      buffer,
      [],
      Utils.indent(state.indentation) <> text <> new_line(state)
    )
  end

  def render(buffer, state, %Components{} = ast) do
  end

  def render(buffer, state, %Slot{} = ast) do
  end

  def render(buffer, state, %ElementList{} = ast) do
  end

  def render(buffer, state, %NonvoidElementsAliases{} = ast) do
    current_indent = Utils.indent(state.indentation)

    inside_new_lines = if ast.meta.whitespace == :tight, do: "", else: "\n"
    new_indent = if ast.meta.whitespace == :tight, do: nil, else: state.indentation + 1

    buffer =
      state.engine.handle_text(
        buffer,
        [],
        "#{current_indent}<#{ast.name}#{Utils.compile_attrs(ast.attrs)}>#{inside_new_lines}"
      )

    buffer =
      if Enum.any?(children(ast.children)) do
        for {child, index} <- Enum.with_index(children(ast.children), 1), reduce: buffer do
          buffer ->
            render(
              buffer,
              %{
                state
                | indentation: new_indent,
                  terminal_node: index == length(children(ast.children))
              },
              child
            )
        end
      else
        buffer
      end

    state.engine.handle_text(
      buffer,
      [],
      "#{inside_new_lines}#{Utils.indent(if(ast.meta.whitespace == :loose, do: state.indentation, else: nil))}</#{ast.name}>#{new_line(state)}"
    )
  end

  def render(buffer, state, %VoidElementsAliases{} = ast) do
  end

  def render(buffer, state, %AnonymousFunctions{} = ast) do
  end

  def render(buffer, state, %RightArrow{} = ast) do
  end

  def render(buffer, state, %DoExpressions{} = ast) do
  end

  def render(buffer, state, %Match{} = ast) do
  end

  def render(buffer, state, %Default{} = ast) do
  end

  defp children(%ElementList{children: children}), do: children
  defp children(list) when is_list(list), do: list

  def new_line(%{terminal_node: false}), do: "\n"
  def new_line(%{terminal_node: true}), do: ""
end
