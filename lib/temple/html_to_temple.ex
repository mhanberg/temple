defmodule Temple.HtmlToTemple do
  @moduledoc false

  @tags Temple.Html.void_elements() ++
          Temple.Html.nonvoid_elements() ++ Temple.Svg.elements() ++ [:html]

  def parse(doc) do
    result =
      doc
      |> Floki.parse()
      |> do_parse(0)

    {:ok, result}
  end

  def do_parse({tag, [], []}, indent) do
    tag = tag |> find_tag
    (Temple.Utils.kebab_to_snake(tag) <> "()\n") |> pad_indent(indent)
  end

  def do_parse({tag, attrs, []}, indent) do
    tag = tag |> find_tag
    (Temple.Utils.kebab_to_snake(tag) <> build_attrs(attrs) <> "\n") |> pad_indent(indent)
  end

  def do_parse({tag, attrs, [""]}, indent), do: do_parse({tag, attrs, []}, indent)

  def do_parse({tag, attrs, children}, indent) do
    tag = tag |> find_tag

    head =
      (Temple.Utils.kebab_to_snake(tag) <> build_attrs(attrs) <> " do\n")
      |> pad_indent(indent)

    parsed_childs =
      for child <- children do
        do_parse(child, indent + 1)
      end
      |> Enum.join("\n")

    head <> parsed_childs <> pad_indent("end\n", indent)
  end

  def do_parse(text, indent) when is_binary(text) do
    (~s|text "| <> text <> ~s|"\n|) |> pad_indent(indent)
  end

  defp build_attrs([]), do: ""

  defp build_attrs(attrs) do
    attrs =
      for {key, value} <- attrs do
        wrap_in_quotes(key) <> ~s|: "| <> value <> ~s|"|
      end
      |> Enum.join(", ")

    " " <> attrs
  end

  defp wrap_in_quotes(key) do
    if Regex.match?(~r/[^a-zA-Z_]/, key) do
      ~s|"| <> key <> ~s|"|
    else
      key
    end
  end

  defp pad_indent(paddable, indent) do
    String.pad_leading(paddable, 2 * indent + String.length(paddable))
  end

  defp find_tag(tag),
    do: @tags |> Enum.find(fn x -> String.downcase(to_string(x)) == tag end)
end
