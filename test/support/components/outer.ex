defmodule Temple.Components.Outer do
  use Temple.Component

  render do
    c Temple.Components.Inner, outer_id: "from-outer" do
      @inner_content
    end
  end
end
