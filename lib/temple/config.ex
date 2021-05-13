defmodule Temple.Config do
  @moduledoc false

  def mode do
    case Application.get_env(:temple, :mode, :normal) do
      :normal ->
        %{
          component_function: "Temple.Component.__component__",
          render_block_function: "Temple.Component.__render_block__",
          renderer: fn module -> Macro.to_string(module) end
        }

      :live_view ->
        %{
          component_function: "component",
          render_block_function: "render_block",
          renderer: fn module -> "&" <> Macro.to_string(module) <> ".render/1" end
        }
    end
  end
end
