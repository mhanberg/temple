defmodule Temple.Components.WithSlot do
  use Temple.Component

  render do
    div do
      slot :header, value: "Header"

      div class: "wrapped" do
        @inner_content
      end
    end
  end
end
