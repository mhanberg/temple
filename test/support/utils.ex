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
end
