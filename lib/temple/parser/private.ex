defmodule Temple.Parser.Private do
  @moduledoc false

  def snake_to_kebab(stringable),
    do: stringable |> to_string() |> String.replace_trailing("_", "") |> String.replace("_", "-")

  def kebab_to_snake(stringable),
    do: stringable |> to_string() |> String.replace("-", "_")

  def compile_attrs([]), do: ""

  def compile_attrs([attrs]) when is_list(attrs) do
    compile_attrs(attrs)
  end

  def compile_attrs(attrs) when is_list(attrs) do
    if Keyword.keyword?(attrs) do
      for {name, value} <- attrs, into: "" do
        name = snake_to_kebab(name)

        case value do
          {_, _, _} = macro ->
            " " <> name <> "=\"<%= " <> Macro.to_string(macro) <> " %>\""

          value ->
            " " <> name <> "=\"" <> to_string(value) <> "\""
        end
      end
    else
      "<%= Temple.Parser.Private.runtime_attrs(" <>
        (attrs |> List.first() |> Macro.to_string()) <> ") %>"
    end
  end

  def runtime_attrs(attrs) do
    {:safe,
     for {name, value} <- attrs, into: "" do
       name = snake_to_kebab(name)

       " " <> name <> "=\"" <> to_string(value) <> "\""
     end}
  end

  def split_args(not_what_i_want) when is_nil(not_what_i_want) or is_atom(not_what_i_want),
    do: {[], []}

  def split_args(args) do
    {do_and_else, args} =
      args
      |> Enum.split_with(fn arg ->
        if Keyword.keyword?(arg) do
          arg
          |> Keyword.drop([:do, :else])
          |> Enum.empty?()
        else
          false
        end
      end)

    {List.flatten(do_and_else), args}
  end

  def split_on_fn([{:fn, _, _} = func | rest], {args_before, _, args_after}) do
    split_on_fn(rest, {args_before, func, args_after})
  end

  def split_on_fn([arg | rest], {args_before, nil, args_after}) do
    split_on_fn(rest, {[arg | args_before], nil, args_after})
  end

  def split_on_fn([arg | rest], {args_before, func, args_after}) do
    split_on_fn(rest, {args_before, func, [arg | args_after]})
  end

  def split_on_fn([], {args_before, func, args_after}) do
    {Enum.reverse(args_before), func, Enum.reverse(args_after)}
  end

  def pop_compact?([]), do: {false, []}
  def pop_compact?([args]) when is_list(args), do: pop_compact?(args)

  def pop_compact?(args) do
    Keyword.pop(args, :compact, false)
  end

  def traverse(buffer, {:__block__, _meta, block}) do
    traverse(buffer, block)
  end

  def traverse(buffer, [first | rest]) do
    traverse(buffer, first)

    traverse(buffer, rest)
  end

  def traverse(buffer, original_macro) do
    Temple.Parser.parsers()
    |> Enum.reduce_while(original_macro, fn parser, macro ->
      with true <- parser.applicable?(macro),
           :ok <- parser.run(macro, buffer) do
        {:halt, macro}
      else
        {:component_applied, adjusted_macro} ->
          traverse(buffer, adjusted_macro)

          {:halt, adjusted_macro}

        false ->
          {:cont, macro}
      end
    end)
  end
end
