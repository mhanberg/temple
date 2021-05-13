defmodule Temple.Components.Section do
  import Temple.Component

  render do
    section class: "foo!" do
      slot :default
    end
  end
end
