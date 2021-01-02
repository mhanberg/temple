defmodule TempleDemoWeb.Component.Inner do
  use Temple.Component

  render do
    div id: "inner", outer_id: @outer_id do
      @inner_content
    end
  end
end
