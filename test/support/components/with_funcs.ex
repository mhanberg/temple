defmodule Temple.Components.WithFuncs do
  import Temple.Component

  def get_class(:bar) do
    "barbarbar"
  end

  def get_class(_) do
    "foofoofoo"
  end

  render do
    div class: get_class(@foo) do
      slot :default
    end
  end
end
