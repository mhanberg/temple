defmodule Temple.Components.HasTemple do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      div class: @temple[:class] do
        @children
      end
    end
  end
end
