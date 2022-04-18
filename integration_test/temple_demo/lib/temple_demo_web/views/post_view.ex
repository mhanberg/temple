defmodule TempleDemoWeb.PostView do
  use TempleDemoWeb, :view

  def thing(), do: "foobar"

  def headers(assigns) do
    temple do
      thead id: thing() do
        tr do
          slot :default
        end
      end
    end
  end
end
