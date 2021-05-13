defmodule Temple.ComponentTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  test "renders components using Phoenix.View.render_layout" do
    result =
      temple do
        div class: "font-bold" do
          "Hello, world"
        end

        c Temple.Components.Component do
          aside class: "foobar" do
            "I'm a component!"
          end
        end
      end

    assert evaluate_template(result) ==
             ~s{<div class="font-bold">Hello, world</div><div><aside class="foobar">I'm a component!</aside></div>}
  end

  test "function components can accept local assigns" do
    result =
      temple do
        div class: "font-bold" do
          "Hello, world"
        end

        c Temple.Components.Component2, class: "bg-red" do
          "I'm a component!"
        end
      end

    assert evaluate_template(result) ==
             ~s{<div class="font-bold">Hello, world</div><div class="bg-red">I'm a component!</div>}
  end

  test "function components can use other components" do
    result =
      temple do
        c Temple.Components.Outer do
          "outer!"
        end

        c Temple.Components.Inner, outer_id: "set by root inner" do
          "inner!"
        end
      end

    assert evaluate_template(result) == ~s"""
           <div id="inner" outer-id="from-outer">outer!</div>
           <div id="inner" outer-id="set by root inner">inner!</div>
           """
  end

  test "components can use functions from their modules" do
    result =
      temple do
        c Temple.Components.WithFuncs, foo: :bar do
          "doo doo"
        end
      end

    assert evaluate_template(result) == ~s{<div class="barbarbar">doo doo</div>}
  end

  test "components can be void elements" do
    result =
      temple do
        c Temple.Components.VoidComponent, foo: :bar
      end

    assert evaluate_template(result) == ~s{<div class="void!!">bar</div>}
  end

  test "components can have named slots" do
    assigns = %{name: "bob"}

    result =
      temple do
        c Temple.Components.WithSlot do
          slot :header, %{value: val} do
            div do
              "the value is #{val}"
            end
          end

          button class: "btn", phx_click: :toggle do
            @name
          end
        end
      end

    assert evaluate_template(result, assigns) ==
             ~s{<div><div>the value is Header</div><div class="wrapped"><button class="btn" phx-click="toggle">bob</button></div></div>}
  end
end
