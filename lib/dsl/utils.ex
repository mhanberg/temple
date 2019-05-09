defmodule Dsl.Utils do
  @moduledoc false

  def put_open_tag(buff, el, attrs) when is_list(attrs) do
    put_buffer(buff, "<#{el}#{compile_attrs(attrs)}>")
  end

  def put_open_tag(buff, el, content) when is_binary(content) do
    put_buffer(buff, "<#{el}>")
    put_buffer(buff, content)
  end

  def put_close_tag(buff, el) do
    put_buffer(buff, "</#{el}>")
  end

  def from_safe({:safe, partial}) do
    partial
  end

  def from_safe(partial) do
    partial |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
  end

  def insert_props({:@, _, [{name, _, _}]}, props) when is_atom(name) do
    props[name]
  end

  def insert_props(ast, _inner), do: ast

  def compile_attrs([]), do: ""

  def compile_attrs(attrs) do
    for {name, value} <- attrs, into: "" do
      name = name |> Atom.to_string() |> String.replace("_", "-")

      " " <> name <> "=\"" <> to_string(value) <> "\""
    end
  end

  def start_buffer(initial_buffer), do: Agent.start(fn -> initial_buffer end)
  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])
  def get_buffer(buff), do: Agent.get(buff, & &1)
  def stop_buffer(buff), do: Agent.stop(buff)
end
