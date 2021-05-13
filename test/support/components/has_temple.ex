defmodule Temple.Components.HasTemple do
  import Temple.Component

  render do
    div class: @temple[:class] do
      slot :default
    end
  end
end
