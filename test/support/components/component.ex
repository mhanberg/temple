defmodule Temple.Components.Component do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      div class: @assign do
        @children
      end
    end
  end
end
