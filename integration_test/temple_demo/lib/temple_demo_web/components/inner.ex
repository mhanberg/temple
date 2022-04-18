defmodule TempleDemoWeb.Component.Inner do
  import Temple

  def render(assigns) do
    temple do
      div id: "inner", outer_id: @outer_id do
        slot :default
      end
    end
  end
end
