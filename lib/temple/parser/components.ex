defmodule Temple.Parser.Components do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct content: nil, attrs: [], children: []

  @impl Temple.Parser
  def applicable?({:c, _, _}) do
    true
  end

  def applicable?(_), do: false

  @impl Temple.Parser
  def run({:c, _meta, [component_module | args]}) do
    {assigns, block} =
      case args do
        [assigns, [do: block]] ->
          {assigns, block}

        [[do: block]] ->
          {[], block}

        [assigns] ->
          {assigns, nil}

        _ ->
          {[], nil}
      end

    children =
      if block == nil do
        []
      else
        Temple.Parser.parse(block)
      end

    Temple.Ast.new(
      __MODULE__,
      meta: %{type: :component},
      content: Macro.expand_once(component_module, __ENV__),
      attrs: assigns,
      children: children
    )
  end

  defimpl Temple.EEx do
    def to_eex(%{content: component_module, attrs: assigns, children: []}) do
      [
        "<%= Phoenix.View.render",
        " ",
        Macro.to_string(component_module),
        ", ",
        ":self,",
        " ",
        Macro.to_string(assigns),
        " ",
        "%>"
      ]
    end

    def to_eex(%{content: component_module, attrs: assigns, children: children}) do
      [
        "<%= Phoenix.View.render_layout ",
        Macro.to_string(component_module),
        ", ",
        ":self",
        ", ",
        Macro.to_string(assigns),
        " ",
        "do %>",
        "\n",
        for(child <- children, do: Temple.EEx.to_eex(child)),
        "\n",
        "<% end %>"
      ]
    end
  end
end
