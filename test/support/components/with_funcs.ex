defmodule Temple.Components.WithFuncs do
  use Temple.Component

  def get_class(:bar) do
    "barbarbar"
  end

  def get_class(_) do
    "foofoofoo"
  end

  render do
    div class: get_class(@foo) do
      @inner_content
    end
  end
end
