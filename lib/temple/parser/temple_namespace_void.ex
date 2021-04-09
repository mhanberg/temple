defmodule Temple.Parser.TempleNamespaceVoid do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  alias Temple.Parser

  @impl Parser
  def applicable?({{:., _, [{:__aliases__, _, [:Temple]}, name]}, _meta, _args}) do
    name in Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Parser
  def run({name, meta, args}) do
    {:., _, [{:__aliases__, _, [:Temple]}, name]} = name

    Temple.Parser.VoidElementsAliases.run({name, meta, args})
  end
end
