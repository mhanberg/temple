defmodule Temple.Parser.Components do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct module: nil, assigns: [], children: []

  @impl Temple.Parser
  def applicable?({:c, _, _}) do
    true
  end

  def applicable?(_), do: false

  @impl Temple.Parser
  def run({:c, _meta, [component_module | args]}) do
    {do_and_else, args} =
      args
      |> Temple.Parser.Utils.split_args()

    {do_and_else, assigns} = Temple.Parser.Utils.consolidate_blocks(do_and_else, args)

    children =
      if do_and_else[:do] == nil do
        []
      else
        Temple.Parser.parse(do_and_else[:do])
      end

    Temple.Ast.new(__MODULE__,
      module: Macro.expand_once(component_module, __ENV__),
      assigns: assigns,
      children: children
    )
  end

  defimpl Temple.Generator do
    def to_eex(%{module: module, assigns: assigns, children: []}) do
      [
        "<%= Phoenix.View.render",
        " ",
        Macro.to_string(module),
        ", ",
        ":self,",
        " ",
        Macro.to_string(assigns),
        " ",
        "%>"
      ]
    end

    def to_eex(%{module: module, assigns: assigns, children: children}) do
      [
        "<%= Phoenix.View.render_layout ",
        Macro.to_string(module),
        ", ",
        ":self",
        ", ",
        Macro.to_string(assigns),
        " ",
        "do %>",
        "\n",
        for(child <- children, do: Temple.Generator.to_eex(child)),
        "\n",
        "<% end %>"
      ]
    end
  end
end
