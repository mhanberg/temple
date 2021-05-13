defmodule Temple.Components.Outer do
  import Temple.Component

  render do
    c Temple.Components.Inner, outer_id: "from-outer" do
      slot :default, %{}
    end
  end
end
