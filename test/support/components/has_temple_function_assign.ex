defmodule Temple.Components.HasTempleFunctionAssign do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      div Keyword.put(@temple, :class, "flex #{@temple[:class]}") do
        @children
      end
    end
  end
end
