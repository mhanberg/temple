defmodule Temple.Components.VoidComponent do
  import Temple.Component

  render do
    div class: "void!!" do
      "bar"
    end
  end
end
