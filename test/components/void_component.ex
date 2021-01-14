defmodule Temple.Components.VoidComponent do
  use Temple.Component

  render do
    div class: "void!!" do
      "bar"
    end
  end
end
