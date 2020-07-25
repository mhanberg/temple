defmodule Temple.Components.Section do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      section class: "foo!" do
        @children
      end
    end
  end
end
