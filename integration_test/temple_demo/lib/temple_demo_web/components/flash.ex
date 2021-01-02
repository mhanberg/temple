defmodule TempleDemoWeb.Component.Flash do
  use Temple.Component

  render do
    div class: "alert alert-#{@type}", style: "border: solid 5px pink" do
      @inner_content
    end
  end
end
