defmodule Temple.Components.Section do
  use Temple.Component

  render do
    section class: "foo!" do
      @inner_content
    end
  end
end
