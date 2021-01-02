defmodule TempleDemoWeb.Component.Outer do
  use Temple.Component
  alias TempleDemoWeb.Component.Inner

  render do
    c Inner, outer_id: "from-outer" do
      @inner_content
    end
  end
end
