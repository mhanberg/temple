defmodule Temple.Converter do
  @moduledoc false

  @boolean_attributes ~w[
    allowfullscreen
    async
    autofocus
    autoplay
    checked
    controls
    default
    defer
    disabled
    formnovalidate
    ismap
    itemscope
    loop
    multiple
    muted
    nomodule
    novalidate
    open
    playsinline
    readonly
    required
    reversed
    selected
    truespeed
  ]

  def convert(html) do
    html
    |> Floki.parse_fragment!()
    |> to_temple()
    |> :erlang.iolist_to_binary()
    |> Code.format_string!()
    |> :erlang.iolist_to_binary()
  end

  def to_temple([]) do
    []
  end

  def to_temple([{tag, attrs, children} | rest]) do
    [
      to_string(tag),
      " ",
      to_temple_attrs(attrs),
      " do\n",
      to_temple(children),
      "end\n"
    ] ++ to_temple(rest)
  end

  def to_temple([{:comment, comment} | rest]) do
    [
      comment
      |> String.split("\n")
      |> Enum.map_join("\n", fn line ->
        if String.trim(line) != "" do
          "# #{line}"
        else
          ""
        end
      end),
      "\n"
    ] ++ to_temple(rest)
  end

  def to_temple([text | rest]) when is_binary(text) do
    [
      text
      |> String.split("\n")
      |> Enum.map_join("\n", fn line ->
        if String.trim(line) != "" do
          escaped = String.replace(line, ~s|"|, ~s|\\"|)
          ~s|"#{String.trim(escaped)}"|
        else
          ""
        end
      end),
      "\n"
    ] ++ to_temple(rest)
  end

  defp to_temple_attrs([]) do
    ""
  end

  defp to_temple_attrs(attrs) do
    Enum.map_join(attrs, ", ", fn
      {attr, _value} when attr in @boolean_attributes ->
        to_attr_name(attr) <> ": true"

      {attr, value} ->
        ~s|#{to_attr_name(attr)}: "#{value}"|
    end)
  end

  defp to_attr_name(name) do
    String.replace(name, "-", "_")
  end
end
