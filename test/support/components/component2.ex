defmodule Temple.Components.Component2 do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      div class: @class do
        @children
      end
    end
  end
end
