defmodule Mix.Tasks.Compile.Temple do
  use Mix.Task.Compiler

  @recursive true

  @impl Mix.Task.Compiler
  def run(_) do
    Code.put_compiler_option(
      :parser_options,
      Keyword.put(Code.get_compiler_option(:parser_options), :token_metadata, true)
    )

    {:ok, []}
  end
end
