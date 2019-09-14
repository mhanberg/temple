defmodule Mix.Tasks.Temple.UpdateMdnDocs do
  use Mix.Task

  @html_base_url "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/"
  @svg_base_url "https://developer.mozilla.org/en-US/docs/Web/SVG/Element/"
  @params "?summary&raw"

  @shortdoc "Update the MDN documentation"
  def run(_) do
    IO.puts("Downloading HTML documentation")

    (Temple.Tags.nonvoid_elements() ++ Temple.Tags.void_elements() ++ ["html"])
    |> Enum.map(
      &to_doc(to_string(&1), "./tmp/docs/html/", fn el -> base_url(:html, html_page(el)) end)
    )
    |> Enum.each(&Task.await/1)

    IO.puts("Downloading SVG documentation")

    Temple.Svg.elements()
    |> Enum.map(&Temple.Utils.to_valid_tag(&1))
    |> Enum.map(&to_doc(&1, "./tmp/docs/svg/", fn el -> base_url(:svg, el) end))
    |> Enum.each(&Task.await/1)
  end

  defp to_doc(el, dir_path, url_getter) do
    Task.async(fn ->
      url = url_getter.(el)

      {doc, 0} = System.cmd("curl", ["--silent", url])

      File.mkdir_p!(dir_path)

      doc = HtmlSanitizeEx.strip_tags(doc)

      File.write!(dir_path <> el <> ".txt", doc)
    end)
  end

  defp html_page(el) when el in ["h1", "h2", "h3", "h4", "h5", "h6"] do
    "Heading_Elements"
  end

  defp html_page(el), do: el

  defp base_url(:html, page), do: @html_base_url <> page <> @params
  defp base_url(:svg, page), do: @svg_base_url <> page <> @params
end
