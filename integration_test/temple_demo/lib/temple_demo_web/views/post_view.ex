defmodule TempleDemoWeb.PostView do
  use TempleDemoWeb, :view
  import Temple.Component, only: [defcomp: 2]

  def thing(), do: "foobar"

  defcomp Headers do
    thead id: PostView.thing() do
      tr do 
        @inner_content
      end
    end
  end
end
