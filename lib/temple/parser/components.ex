defmodule Temple.Parser.Components do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Parser

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

    {default_slot, {_, named_slots}} =
      if children = do_and_else[:do] do
        Macro.prewalk(
          children,
          {component_module, %{}},
          fn
            {:c, _, [name | _]} = node, {_, named_slots} ->
              {node, {name, named_slots}}

            {:slot, _, [name | args]} = node, {^component_module, named_slots} ->
              {assigns, slot} = split_assigns_and_children(args, Macro.escape(%{}))

              if is_nil(slot) do
                {node, {component_module, named_slots}}
              else
                {nil,
                 {component_module, Map.put(named_slots, name, %{assigns: assigns, slot: slot})}}
              end

            node, acc ->
              {node, acc}
          end
        )
      else
        {nil, {nil, %{}}}
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
    def to_eex(%{module: module, assigns: assigns, children: children, slots: slots}, indent \\ 0) do
      component_function = Temple.Config.mode().component_function
      renderer = Temple.Config.mode().renderer.(module)

      [
        "#{Parser.Utils.indent(indent)}<%= #{component_function} ",
        renderer,
        ", ",
        Macro.to_string(assigns),
        if not Enum.empty?(children ++ slots) do
          [
            " do %>\n",
            if not Enum.empty?(children) do
              [
                "#{Parser.Utils.indent(indent + 1)}<% {:default, _} -> %>\n",
                for(child <- children, do: Temple.Generator.to_eex(child, indent + 2))
              ]
            else
              ""
            end,
            for slot <- slots do
              [
                "#{Parser.Utils.indent(indent + 1)}<% {:",
                to_string(slot.name),
                ", ",
                "#{Macro.to_string(slot.assigns)}} -> %>\n",
                for(child <- slot.content, do: Temple.Generator.to_eex(child, indent + 2))
              ]
            end,
            "\n#{Parser.Utils.indent(indent)}<% end %>"
          ]
        else
          " %>"
        end
      ]
    end
  end
end
