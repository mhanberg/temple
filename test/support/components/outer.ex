defmodule Temple.Components.Outer do
  @behaviour Temple.Component

  @impl Temple.Component
  def render do
    quote do
      inner outer_id: "from-outer" do
        @children
      end
    end
  end
end
