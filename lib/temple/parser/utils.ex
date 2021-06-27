defmodule Temple.Parser.Utils do
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

        cond do
          (not is_binary(value) && Macro.quoted_literal?(value)) || match?({_, _, _}, value) ->
            ~s|<%= {:safe, Temple.Parser.Utils.build_attr("#{name}", #{Macro.to_string(value)})} %>|

          true ->
            " " <> name <> "=\"" <> to_string(value) <> "\""
        end
      end
    else
      "<%= Temple.Parser.Utils.runtime_attrs(" <>
        (attrs |> List.first() |> Macro.to_string()) <> ") %>"
    end
  end

  def runtime_attrs(attrs) do
    {:safe,
     for {name, value} <- attrs, name not in [:inner_block, :inner_content], into: "" do
       name = snake_to_kebab(name)

       build_attr(name, value)
     end}
  end

  def build_attr(name, true) do
    " " <> name
  end

  def build_attr(_name, false) do
    ""
  end

  def build_attr(name, value) do
    " " <> name <> "=\"" <> to_string(value) <> "\""
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

  def consolidate_blocks(blocks, args) do
    case args do
      [args] when is_list(args) ->
        {do_value, args} = Keyword.pop(args, :do)

        {Keyword.put_new(blocks, :do, do_value), args}

      _ ->
        {blocks, args}
    end
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
end
