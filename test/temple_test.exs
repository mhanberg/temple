defmodule TempleTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  test "renders an attribute on a div passed as a variable" do
    result =
      temple do
        div class: "hello" do
          div class: "hi"
        end
      end

    assert result == ~s{<div class="hello"><div class="hi"></div></div>}
  end

  test "renders an attribute on a div passed as a variable as eex" do
    hello = "hello"

    result =
      temple do
        div class: hello do
          div class: "hi"
        end
      end

    assert result == ~s{<div class="<%= hello %>"><div class="hi"></div></div>}
  end
end
