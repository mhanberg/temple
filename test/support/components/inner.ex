defmodule Temple.Components.Inner do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      div id: "inner", outer_id: @outer_id do
        @children
      end
    end
  end
end
