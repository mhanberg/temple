defmodule Temple.Components.HasTemple do
  use Temple.Component

  render do
    div class: @temple[:class] do
      @inner_content
    end
  end
end
