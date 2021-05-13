defmodule Temple.Components.Component2 do
  import Temple.Component

  render do
    div class: @class do
      slot :default
    end
  end
end
