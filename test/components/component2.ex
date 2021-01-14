defmodule Temple.Components.Component2 do
  use Temple.Component

  render do
    div class: @class do
      @inner_content
    end
  end
end
