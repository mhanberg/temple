defmodule Temple.Parser.VoidElementsAliases do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct name: nil, attrs: []

  @impl Temple.Parser
  def applicable?({name, _, _}) do
    name in Temple.Parser.void_elements_aliases()
  end

  def applicable?(_), do: false

  @impl Temple.Parser
  def run({name, _, args}) do
    args =
      case Temple.Parser.Utils.split_args(args) do
        {_, [args]} when is_list(args) ->
          args

        {_, args} ->
          args
      end

    name = Temple.Parser.void_elements_lookup()[name]

    Temple.Ast.new(__MODULE__, name: name, attrs: args)
  end
end
