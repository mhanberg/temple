defmodule TempleDemoWeb.Component.Flash do
  import Temple, only: [component: 2], warn: false
  import Temple.Component

  render do
    div class: "alert alert-#{@type}", style: "border: solid 5px pink" do
      slot :default
    end
  end
end
