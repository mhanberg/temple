defmodule Temple do
  defmacro __using__(_) do
    quote location: :keep do
      import Temple
    end
  end

  def snake_to_kebab(stringable),
    do: stringable |> to_string() |> String.replace_trailing("_", "") |> String.replace("_", "-")

  def kebab_to_snake(stringable),
    do: stringable |> to_string() |> String.replace("-", "_")

  def compile_attrs([]), do: ""

  def compile_attrs([attrs]) when is_list(attrs) do
    compile_attrs(attrs)
  end

  def compile_attrs(attrs) do
    for {name, value} <- attrs, into: "" do
      name = snake_to_kebab(name)

      " " <> name <> "=\"" <> to_string(value) <> "\""
    end
  end

  def traverse({name, _meta, args}) do
    {block, args} =
      args
      |> Enum.sort(fn
        {:do, _}, _ ->
          true

        _, _ ->
          false
      end)
      |> case do
        [[do: block] | args] ->
          {block, args}

        [args] ->
          {nil, args}
      end

    case name do
      name when name in [:div] ->
        Agent.update(:buffer, fn buffer -> ["<#{name}#{compile_attrs(args)}>" | buffer] end)
        traverse(block)
        Agent.update(:buffer, fn buffer -> ["</#{name}>" | buffer] end)

      name ->
        Agent.update(:buffer, fn buffer -> ["<%= #{name}%>" | buffer] end)
        traverse(block)
    end
  end

  def traverse([first | rest]) do
    traverse(first)

    traverse(rest)
  end

  def traverse(arg) when arg in [nil, []] do
    nil
  end

  defmacro temple([do: block] = _block) do
    {:ok, _} = Agent.start_link(fn -> [] end, name: :buffer)

    block
    |> traverse()

    buf =
      Agent.get(:buffer, & &1)
      |> Enum.reverse()
      |> Enum.join("")

    quote location: :keep do
      import Kernel, except: [div: 2, use: 1, use: 2]
      unquote(buf)
    end
  end
end
