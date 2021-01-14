defmodule Temple.Components.SlotComponent do
  use Temple.Component

  render do
    section class: "foo!" do
      slot(@slots.foo, this: "is an assign passed in from slotcomponent")

      @inner_content
    end
  end
end
