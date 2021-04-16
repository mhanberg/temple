defmodule Temple.Parser.Slot do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct name: nil, args: []

  @impl true
  def applicable?({:slot, _, _}) do
    true
  end

  def applicable?(_), do: false

  @impl true
  def run({:slot, _, [slot_name | [args]]}) do
    Temple.Ast.new(__MODULE__, name: slot_name, args: args)
  end

  defimpl Temple.Generator do
    def to_eex(%{name: name, args: args}) do
      [
        "<%= @__temple_slots__.",
        to_string(name),
        ".(",
        Macro.to_string(quote(do: Enum.into(unquote(args), %{}))),
        ") %>"
      ]
    end
  end
end
