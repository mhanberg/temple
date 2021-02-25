defmodule Temple.Parser.Components do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Buffer

  def applicable?({keyword, _, _}) when keyword in [:c, :slot] do
    true
  end

  def applicable?(_), do: false

  def run({:c, _meta, [component_module | args]}, buffers, buffer) do
    import Temple.Parser.Private

    {assigns, children} = split_assigns_and_children(args)

    buffers =
      if children do
        # start bit: this bit extracts and compiles slot definintions form the call site of a component
        {default_slot, named_slots} =
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

        slots = Map.put(named_slots, :default, %{assigns: nil, slot: default_slot})

        buffers =
          for {name, %{assigns: assigns, slot: slot}} <- slots, reduce: buffers do
            buffers ->
              {:ok, slot_buffer} = Buffer.start_link()

              Buffer.put(slot_buffer, {:assigns, assigns})

              buffers
              |> Map.put(name, slot_buffer)
              |> traverse(name, slot)
          end

        # end bit

        Buffer.put(
          buffer,
          "<%= Phoenix.View.render_layout #{Macro.to_string(component_module)}, :default, #{
            Macro.to_string(assigns)
          } do %>"
        )

        buffers = traverse(buffers, buffer, default_slot)

        Buffer.put(buffer, "<% end %>")

        buffers
      else
        Buffer.put(
          buffer,
          "<%= Phoenix.View.render #{Macro.to_string(component_module)}, :component, #{
            Macro.to_string(assigns)
          } %>"
        )

        buffers
      end

    buffers
  end

  # this funciton compiles slot calls from within a component module
  def run({:slot, _meta, [slot_name | [assigns]]}, buffers, buffer) do
    Buffer.put(
      buffers[buffer],
      "<%= Phoenix.View.render __MODULE__, #{Macro.to_string(slot_name)}, #{
        Macro.to_string(assigns)
      } %>"
    )

    buffers
  end

  defp split_assigns_and_children(args, empty \\ []) do
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
