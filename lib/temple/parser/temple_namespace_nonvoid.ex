defmodule Temple.Parser.TempleNamespaceNonvoid do
  @moduledoc false
  @behaviour Temple.Ast

  alias Temple.Parser

  @impl true
  def applicable?({{:., _, [{:__aliases__, _, [:Temple]}, name]}, _meta, _args}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  @impl true
  def run({name, meta, args}) do
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name
    Temple.Parser.NonvoidElementsAliases.run({name, meta, args})
  end
end
