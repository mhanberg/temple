defmodule Temple.Parser.TempleNamespaceNonvoid do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser

  @impl Parser
  def applicable?({{:., _, [{:__aliases__, _, [:Temple]}, name]}, _meta, _args}) do
    name in Parser.nonvoid_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, meta, args}) do
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name
    Temple.Parser.NonvoidElementsAliases.run({name, meta, args})
  end
end
