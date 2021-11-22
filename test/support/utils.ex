defmodule Temple.Support.Utils do
  defmacro __using__(_) do
    quote do
      import Kernel, except: [==: 2, =~: 2]
      import unquote(__MODULE__)
    end
  end

  def a == b when is_binary(a) and is_binary(b) do
    a = String.replace(a, "\n", "")
    b = String.replace(b, "\n", "")

    Kernel.==(a, b)
  end

  def a =~ b when is_binary(a) and is_binary(b) do
    a = String.replace(a, "\n", "")
    b = String.replace(b, "\n", "")

    Kernel.=~(a, b)
  end

  def env do
    require Temple.Component

    __ENV__
  end

  def evaluate_template(template, assigns \\ %{}) do
    template
    |> EEx.compile_string(engine: Phoenix.HTML.Engine, trim: true)
    |> Code.eval_quoted([assigns: assigns], env())
    |> elem(0)
    |> Phoenix.HTML.safe_to_string()
  end

  @doc """
  Converts an iolist to a binary and appends a new line.
  """
  def iolist_to_binary(iolist) do
    iolist
    |> :erlang.iolist_to_binary()
    |> append_new_line()
  end

  @doc """
  Appends a new line to a string.
  """
  def append_new_line(string) do
    string <> "\n"
  end
end
