defmodule TempleDemoWeb.Component.Outer do
  alias TempleDemoWeb.Component.Inner

  import Temple

  def render(assigns) do
    temple do
      c &Inner.render/1, outer_id: "from-outer" do
        slot :default
      end
    end
  end
end
