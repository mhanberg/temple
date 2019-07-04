defmodule Mix.Tasks.UpdateMdnDocs do
  use Mix.Task

  @baseurl "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/"
  @params "?summary&raw"

  @shortdoc "Update the MDN documentation"
  def run(_) do
    IO.puts "Downloading MDN documentation"
    (Temple.Tags.nonvoid_elements() ++ Temple.Tags.void_elements())
    |> Enum.map(fn el ->
      Task.async(fn ->
        el = to_string(el)

        page =
          if Enum.any?(["h1", "h2", "h3", "h4", "h5", "h6"], &(&1 == el)) do
            "Heading_Elements"
          else
            el
          end

        {doc, 0} = System.cmd("curl", ["--silent", @baseurl <> page <> @params])
        File.mkdir_p!("./tmp/docs/")

        path = "./tmp/docs/" <> el <> ".txt"
        doc = HtmlSanitizeEx.strip_tags(doc)

        File.write!(path, doc)
      end)
    end)
    |> Enum.each(&Task.await/1)
  end
end
