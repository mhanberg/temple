defmodule Temple.Parser.Components do
  @moduledoc false
  @behaviour Temple.Parser

  alias Temple.Buffer

  def applicable?({:c, _, _}) do
    true
  end

  def applicable?(_), do: false

  def run({:c, _meta, [component_module | args]}, buffer) do
    import Temple.Parser.Private

    {assigns, children} =
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

    if children do
      Buffer.put(
        buffer,
        "<%= Phoenix.View.render_layout #{Macro.to_string(component_module)}, :self, #{
          Macro.to_string(assigns)
        } do %>"
      )

      traverse(buffer, children)

      Buffer.put(buffer, "<% end %>")
    else
      Buffer.put(
        buffer,
        "<%= Phoenix.View.render #{Macro.to_string(component_module)}, :self, #{
          Macro.to_string(assigns)
        } %>"
      )
    end

    :ok
  end
end
