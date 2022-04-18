defmodule TempleDemoWeb.Component.Outer do
  import Temple, only: [component: 2]
  import Temple.Component
  alias TempleDemoWeb.Component.Inner

  render do
    c Inner, outer_id: "from-outer" do
      slot :default
    end
  end
end
