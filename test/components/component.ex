defmodule Temple.Components.Component do
  use Temple.Component

  render do
    div do
      @inner_content
    end
  end
end
