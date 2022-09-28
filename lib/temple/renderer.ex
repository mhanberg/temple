defmodule Temple.Renderer do
  @moduledoc false

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
  alias Temple.Parser.Empty

  alias Temple.Parser.Utils

  @default_engine EEx.SmartEngine

  defmacro compile(opts \\ [], do: block) do
    block
    |> Temple.Parser.parse()
    |> Temple.Renderer.render(opts)

    # |> Temple.Parser.Utils.inspect_ast()
  end

  def render(asts, opts \\ [])

  def render(asts, opts) when is_list(asts) and is_list(opts) do
    engine = Keyword.get(opts, :engine, @default_engine)

    state = %{
      engine: engine,
      indentation: 0,
      terminal_node: false
    }

    buffer = engine.init([])

    buffer =
      for ast <- asts, reduce: buffer do
        buffer ->
          render(buffer, state, ast)
      end

    if function_exported?(engine, :handle_body, 2) do
      engine.handle_body(buffer, root: length(asts) == 1)
    else
      engine.handle_body(buffer)
    end
  end

  def render(buffer, state, %Text{text: text}) do
    t = Utils.indent(state.indentation) <> text <> new_line(state)

    unless t == "" do
      state.engine.handle_text(
        buffer,
        [],
        t
      )
    end
  end

  def render(buffer, state, asts) when is_list(asts) do
    for ast <- asts, reduce: buffer do
      buffer ->
        render(buffer, state, ast)
    end
  end

  def render(buffer, state, %Components{
        function: function,
        assigns: assigns,
        # children: children,
        slots: slots
      }) do
    slot_quotes =
      Enum.group_by(slots, & &1.name, fn slot ->
        slot_buffer = state.engine.handle_begin(buffer)

        slot_buffer =
          for child <- children(slot.content), reduce: slot_buffer do
            slot_buffer ->
              render(slot_buffer, state, child)
          end

        ast = state.engine.handle_end(slot_buffer)

        inner_block =
          quote do
            inner_block unquote(slot.name) do
              unquote(slot.assigns) ->
                unquote(ast)
            end
          end

        {:%{}, [],
         [
           __slot__: slot.name,
           inner_block: inner_block
         ]}
      end)

    assigns =
      {:%{}, [],
       assigns
       |> Map.new()
       |> Map.merge(slot_quotes)
       |> Enum.to_list()}

    expr =
      quote do
        component(
          unquote(function),
          unquote(assigns),
          {__MODULE__, __ENV__.function, __ENV__.file, nil}
        )
      end

    state.engine.handle_expr(buffer, "=", expr)
  end

  def render(buffer, state, %Slot{} = ast) do
    render_slot_func =
      quote do
        render_slot(var!(assigns)[unquote(ast.name)], Map.new(unquote(ast.args)))
      end

    state.engine.handle_expr(buffer, "=", render_slot_func)
  end

  def render(buffer, state, %ElementList{} = ast) do
    render(buffer, state, ast.children)
  end

  def render(buffer, state, %NonvoidElementsAliases{} = ast) do
    current_indent = Utils.indent(state.indentation)

    inside_new_lines = if ast.meta.whitespace == :tight, do: "", else: "\n"
    new_indent = if ast.meta.whitespace == :tight, do: nil, else: state.indentation + 1

    buffer =
      state.engine.handle_text(
        buffer,
        [],
        "#{current_indent}<#{ast.name}"
      )

    buffer =
      for node <- Utils.compile_attrs(ast.attrs), reduce: buffer do
        buffer ->
          case node do
            {:text, text} ->
              state.engine.handle_text(buffer, [], text)

            {:expr, expr} ->
              state.engine.handle_expr(buffer, "=", expr)
          end
      end

    buffer =
      state.engine.handle_text(
        buffer,
        [],
        ">#{inside_new_lines}"
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
      "#{inside_new_lines}#{Utils.indent(if(ast.meta.whitespace == :loose, do: state.indentation, else: nil))}</#{ast.name}>#{new_line(state)}\n"
    )
  end

  def render(buffer, state, %VoidElementsAliases{} = ast) do
    current_indent = Utils.indent(state.indentation)

    buffer =
      state.engine.handle_text(
        buffer,
        [],
        "#{current_indent}<#{ast.name}"
      )

    buffer =
      for node <- Utils.compile_attrs(ast.attrs), reduce: buffer do
        buffer ->
          case node do
            {:text, text} ->
              state.engine.handle_text(buffer, [], text)

            {:expr, expr} ->
              state.engine.handle_expr(buffer, "=", expr)
          end
      end

    state.engine.handle_text(buffer, [], ">\n")
  end

  def render(buffer, state, %AnonymousFunctions{} = ast) do
    new_buffer = state.engine.handle_begin(buffer)

    new_buffer =
      for child <- children(ast.children), child != nil, reduce: new_buffer do
        new_buffer ->
          render(new_buffer, state, child)
      end

    new_buffer = state.engine.handle_text(new_buffer, [], "\n")

    inner_quoted = state.engine.handle_end(new_buffer)

    {name, meta, args} = ast.elixir_ast

    {args, {func, fmeta, [{arrow, arrowmeta, [first, _block]}]}, args2} =
      Temple.Parser.Utils.split_on_fn(args, {[], nil, []})

    full_ast =
      {name, meta, args ++ [{func, fmeta, [{arrow, arrowmeta, [first, inner_quoted]}]}] ++ args2}

    state.engine.handle_expr(buffer, "=", full_ast)
  end

  def render(buffer, state, %RightArrow{elixir_ast: elixir_ast} = ast) do
    new_buffer = state.engine.handle_begin(buffer)

    new_buffer =
      for child <- children(ast.children), child != nil, reduce: new_buffer do
        new_buffer ->
          render(new_buffer, state, child)
      end

    inner_quoted = state.engine.handle_end(new_buffer)

    {func, meta, [first]} = elixir_ast

    full_ast = {func, meta, [first | [inner_quoted]]}

    state.engine.handle_expr(buffer, "", full_ast)
  end

  def render(buffer, state, %DoExpressions{} = ast) do
    {func, meta, args} = ast.elixir_ast
    new_buffer = state.engine.handle_begin(buffer)

    [do_block, else_block] = ast.children

    do_inner_quoted =
      case do_block do
        [%RightArrow{} | _] = bodies ->
          for b <- bodies do
            new_buffer = state.engine.handle_begin(buffer)

            new_buffer = render(new_buffer, state, b)

            {:__block__, _, [quoted | _]} = state.engine.handle_end(new_buffer)
            quoted
          end

        block ->
          for child <- children(block), child != nil, reduce: new_buffer do
            new_buffer ->
              render(new_buffer, state, child)
          end
          |> state.engine.handle_end()
      end

    else_inner_quoted =
      if else_block do
        case else_block do
          [%RightArrow{} | _] = bodies ->
            for b <- bodies do
              new_buffer = state.engine.handle_begin(buffer)

              new_buffer = render(new_buffer, state, b)

              {:__block__, _, [quoted | _]} = state.engine.handle_end(new_buffer)
              quoted
            end

          block ->
            for child <- children(block), child != nil, reduce: new_buffer do
              new_buffer ->
                render(new_buffer, state, child)
            end
            |> state.engine.handle_end()
        end
      end

    new_args =
      then([do: do_inner_quoted], fn args ->
        if else_inner_quoted do
          Keyword.put(args, :else, else_inner_quoted) |> Enum.reverse()
        else
          args
        end
      end)

    full_ast = {func, meta, args ++ [new_args]}

    state.engine.handle_expr(buffer, "=", full_ast)
  end

  def render(buffer, state, %Match{elixir_ast: elixir_ast}) do
    state.engine.handle_expr(buffer, "", elixir_ast)
  end

  def render(buffer, state, %Default{elixir_ast: elixir_ast}) do
    buffer =
      if state.indentation && state.indentation > 0 do
        state.engine.handle_text(buffer, [], Utils.indent(state.indentation))
      else
        buffer
      end

    buffer = state.engine.handle_expr(buffer, "=", elixir_ast)

    if not state.terminal_node do
      state.engine.handle_text(buffer, [], "\n")
    else
      buffer
    end
  end

  def render(buffer, _state, %Empty{}), do: buffer

  defp children(%ElementList{children: children}), do: children
  defp children(list) when is_list(list), do: list

  def new_line(%{terminal_node: false}), do: "\n"
  def new_line(%{terminal_node: true}), do: ""
end
