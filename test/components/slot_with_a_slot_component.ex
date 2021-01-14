defmodule Temple.Components.SlotWithASlotComponent do
  use Temple.Component

  render do
    section class: "foo! from slotwithaslot" do
      slot(@slots.foo, this: "is an assign from the slotwithaslot slot")

      c Temple.Components.SlotComponent do
        slot :foo, %{this: this} do
          span do
            this
          end
        end

        span do
          "inner content from slot"
        end
      end

      @inner_content
    end
  end
end
