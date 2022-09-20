defmodule Temple.Parser.TempleNamespaceVoid do
  @moduledoc false
  @behaviour Temple.Parser

  @impl true
  def applicable?({{:., _, [{:__aliases__, _, [:Temple]}, name]}, _meta, _args}) do
    name in Temple.Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  @impl true
  def run({name, meta, args}) do
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

    Temple.Parser.VoidElementsAliases.run({name, meta, args})
  end
end
