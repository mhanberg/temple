defmodule Temple.Components.Component do
  import Temple.Component

  render do
    div do
      slot :default
    end
  end
end
