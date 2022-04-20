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
  def run({:slot, _, [slot_name | rest]}) do
    args =
      case rest do
        [args] ->
          args

        _ ->
          []
      end

    Temple.Ast.new(__MODULE__, name: slot_name, args: args)
  end
end
