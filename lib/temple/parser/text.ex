defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Ast

  defstruct text: nil

  @impl true
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  @impl true
  def run(text) do
    Temple.Ast.new(__MODULE__, text: text)
  end
end
