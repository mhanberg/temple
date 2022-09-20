defmodule Temple.Parser.Text do
  @moduledoc false
  @behaviour Temple.Parser

  use TypedStruct

  typedstruct do
    field :text, String.t()
  end

  @impl true
  def applicable?(text) when is_binary(text), do: true
  def applicable?(_), do: false

  @impl true
  def run(text) do
    Temple.Ast.new(__MODULE__, text: text)
  end
end
