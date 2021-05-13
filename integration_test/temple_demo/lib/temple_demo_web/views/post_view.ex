defmodule TempleDemoWeb.PostView do
  use TempleDemoWeb, :view

  def thing(), do: "foobar"

  defcomp Headers do
    thead id: PostView.thing() do
      tr do
        slot :default
      end
    end
  end
end
