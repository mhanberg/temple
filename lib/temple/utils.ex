defmodule Temple.Utils do
  @moduledoc false

  def put_open_tag(buff, el, attrs) when is_list(attrs) or is_map(attrs) do
    el = el |> snake_to_kebab

    put_buffer(buff, "<#{el}#{compile_attrs(attrs)}>")
  end

  def put_open_tag(buff, el, content)
      when is_binary(content) or is_number(content) or is_atom(content) do
    el = el |> snake_to_kebab

    put_buffer(buff, "<#{el}>")
    put_buffer(buff, escape_content(content))
  end

  def put_close_tag(buff, el) do
    el = el |> snake_to_kebab

    put_buffer(buff, "</#{el}>")
  end

  def put_void_tag(buff, el, attrs) do
    el = el |> snake_to_kebab

    put_buffer(buff, "<#{el}#{Temple.Utils.compile_attrs(attrs)}>")
  end

  def from_safe({:safe, partial}) do
    partial
  end

  def from_safe(partial) do
    partial |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
  end

  def insert_assigns({:@, _, [{:children, _, _}]}, _, inner) do
    inner
  end

  def insert_assigns({:@, _, [{:assigns, _, _}]}, assigns, _) do
    assigns
  end

  def insert_assigns({:@, _, [{name, _, _}]}, assigns, _) when is_atom(name) do
    quote location: :keep do
      Access.get(unquote_splicing([assigns, name]))
    end
  end

  def insert_assigns(ast, _, _), do: ast

  def compile_attrs([]), do: ""

  def compile_attrs(attrs) do
    for {name, value} <- attrs, into: "" do
      name = snake_to_kebab(name)

      " " <> name <> "=\"" <> to_string(value) <> "\""
    end
  end

  def join_and_escape(markup) do
    markup |> Enum.reverse() |> Enum.join("") |> Phoenix.HTML.raw()
  end

  def start_buffer(initial_buffer), do: Agent.start(fn -> initial_buffer end)
  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])
  def get_buffer(buff), do: Agent.get(buff, & &1)
  def stop_buffer(buff), do: Agent.stop(buff)

  def escape_content(content) do
    content
    |> to_string
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
  end

  defp snake_to_kebab(stringable),
    do: stringable |> to_string() |> String.replace_trailing("_", "") |> String.replace("_", "-")

  def kebab_to_snake(stringable),
    do: stringable |> to_string() |> String.replace("-", "_")

  def __quote__(outer) do
    quote [location: :keep], do: unquote(outer)
  end

  def __insert_assigns__(block, assigns, inner) do
    block
    |> Macro.prewalk(&Temple.Utils.insert_assigns(&1, assigns, inner))
  end

  def doc_path(:html, el), do: "./tmp/docs/html/#{el}.txt"
  def doc_path(:svg, el), do: "./tmp/docs/svg/#{el}.txt"

  def to_valid_tag(tag),
    do: tag |> to_string |> String.replace_trailing("_", "") |> String.replace("_", "-")
end
