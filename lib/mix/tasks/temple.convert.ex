defmodule Mix.Tasks.Temple.Convert do
  use Mix.Task
  @preferred_cli_env :dev
  @shortdoc "Converts HTML to Temple syntax"
  @moduledoc """
  Converts HTML to Temple syntax

  Takes HTML from a file or from stdin and outputs temple syntax to stdout.
  """

  def run(args) do
    html =
      if Enum.count(args) > 0 do
        args |> List.first() |> File.read!()
      else
        IO.read(:stdio, :all)
      end

    {:ok, result} = Temple.HtmlToTemple.parse(html)

    IO.write(result)
  end
end
