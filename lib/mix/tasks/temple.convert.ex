defmodule Mix.Tasks.Temple.Convert do
  use Mix.Task

  @shortdoc "A task to convert vanilla HTML into Temple syntax"
  @moduledoc """
  This task is useful for converting a ton of HTML into Temple syntax.

  > #### Note about EEx and HEEx {: .tip}
  >
  > In the future, this should be able to convert EEx and HEEx as well, but that would involve invoking or forking their parsers. That is certainly doable, but is out of scope for what I needed right now. Contributions are welcome!

  ## Usage

  ```shell
  $ mix temple.convert some_file.html
  ```
  """

  @doc false
  def run(argv) do
    case argv do
      [] ->
        Mix.raise(
          "You need to provide the path to an HTML file you would like to convert to Temple syntax"
        )

      [file] ->
        file
        |> File.read!()
        |> Temple.Converter.convert()
        |> IO.puts()
    end
  end
end
