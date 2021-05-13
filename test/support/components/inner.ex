defmodule Temple.Components.Inner do
  import Temple.Component

  render do
    div id: "inner", outer_id: @outer_id do
      slot :default
    end
  end
end
