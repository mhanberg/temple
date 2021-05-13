defmodule Temple.Components.WithSlot do
  import Temple.Component

  render do
    div do
      slot :header, value: "Header"

      div class: "wrapped" do
        slot :default
      end
    end
  end
end
