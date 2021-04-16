defmodule Temple.Parser.Components do
  @moduledoc false
  @behaviour Temple.Parser

  defstruct module: nil, assigns: [], children: [], slots: []

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

    {default_slot, named_slots} =
      if children = do_and_else[:do] do
        Macro.postwalk(
          children,
          %{},
          fn
            {:slot, _, [name | args]}, named_slots ->
              {assigns, slot} = split_assigns_and_children(args, Macro.escape(%{}))

              {nil, Map.put(named_slots, name, %{assigns: assigns, slot: slot})}

            node, named_slots ->
              {node, named_slots}
          end
        )
      else
        {nil, %{}}
      end

    children =
      if default_slot == nil do
        []
      else
        Temple.Parser.parse(default_slot)
      end

    slots =
      for {name, %{slot: slot, assigns: assigns}} <- named_slots do
        Temple.Ast.new(
          Temple.Parser.Slottable,
          name: name,
          content: Temple.Parser.parse(slot),
          assigns: assigns
        )
      end

    Temple.Ast.new(__MODULE__,
      module: Macro.expand_once(component_module, __ENV__),
      assigns: assigns,
      slots: slots,
      children: children
    )
  end

  defp split_assigns_and_children(args, empty) do
    case args do
      [assigns, [do: block]] ->
        {assigns, block}

      [[do: block]] ->
        {empty, block}

      [assigns] ->
        {assigns, nil}

      _ ->
        {empty, nil}
    end
  end

  defimpl Temple.Generator do
    def to_eex(%{module: module, assigns: assigns, children: [], slots: slots}) do
      [
        "<%= Phoenix.View.render",
        " ",
        Macro.to_string(module),
        ", ",
        ":self,",
        " ",
        "[{:__temple_slots__, %{",
        for slot <- slots do
          [
            to_string(slot.name),
            ": ",
            "fn #{Macro.to_string(slot.assigns)} -> %>",
            for(child <- slot.content, do: Temple.Generator.to_eex(child)),
            "<% end, "
          ]
        end,
        "}} | ",
        Macro.to_string(assigns),
        "]",
        " ",
        "%>"
      ]
    end

    def to_eex(%{module: module, assigns: assigns, children: children, slots: slots}) do
      [
        "<%= Phoenix.View.render_layout ",
        Macro.to_string(module),
        ", ",
        ":self,",
        " ",
        "[{:__temple_slots__, %{",
        for slot <- slots do
          [
            to_string(slot.name),
            ": ",
            "fn #{Macro.to_string(slot.assigns)} -> %>",
            for(child <- slot.content, do: Temple.Generator.to_eex(child)),
            "<% end, "
          ]
        end,
        "}} | ",
        Macro.to_string(assigns),
        "]",
        " do %>",
        "\n",
        for(child <- children, do: Temple.Generator.to_eex(child)),
        "\n",
        "<% end %>"
      ]
    end
  end
end
