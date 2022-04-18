defmodule TempleDemoWeb.Component.Flash do
  import Temple

  def render(assigns) do
    temple do
      div class: "alert alert-#{@type}", style: "border: solid 5px pink" do
        slot :default
      end
    end
  end
end
