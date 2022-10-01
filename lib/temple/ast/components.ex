defmodule Temple.Ast.Components do
  @moduledoc false
  @behaviour Temple.Parser

  use TypedStruct

  typedstruct do
    field :function, function()
    field :assigns, map()
    field :slots, [function()]
  end

  @impl true
  def applicable?({:c, _, _}) do
    true
  end

  def applicable?(_), do: false

  @impl true
  def run({:c, _meta, [component_function | args]}) do
    {do_and_else, args} =
      args
      |> Temple.Ast.Utils.split_args()

    {do_and_else, assigns} = Temple.Ast.Utils.consolidate_blocks(do_and_else, args)

    {default_slot, {_, named_slots}} =
      if children = do_and_else[:do] do
        Macro.prewalk(
          children,
          {component_function, []},
          fn
            {:c, _, [name | _]} = node, {_, named_slots} ->
              {node, {name, named_slots}}

            {:slot, _, [name | args]} = node, {^component_function, named_slots} ->
              {assigns, slot} = split_assigns_and_children(args, nil)

              if is_nil(slot) do
                {node, {component_function, named_slots}}
              else
                {assigns, attributes} = Keyword.pop(assigns, :let)
                new_slot = {name, %{assigns: assigns, slot: slot, attributes: attributes}}
                {nil, {component_function, named_slots ++ [new_slot]}}
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
        [
          Temple.Ast.new(
            Temple.Ast.Slottable,
            name: :inner_block,
            content: Temple.Parser.parse(default_slot)
          )
        ]
      end

    slots =
      for {name, %{slot: slot, assigns: assigns, attributes: attributes}} <- named_slots do
        Temple.Ast.new(
          Temple.Ast.Slottable,
          name: name,
          content: Temple.Parser.parse(slot),
          assigns: assigns,
          attributes: attributes
        )
      end

    slots = children ++ slots

    Temple.Ast.new(__MODULE__,
      function: component_function,
      assigns: assigns,
      slots: slots
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
end
