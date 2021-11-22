defmodule Temple.Components.Link do
  import Temple.Component

  render do
    a! class: "text-blue-400 hover:underline", href: @href do
      slot :default
      slot :foo
    end
  end
end

