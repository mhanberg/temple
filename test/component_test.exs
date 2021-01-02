defmodule Temple.ComponentTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  # `Phoenix.View.render_layout/4` is a phoenix function used for rendering partials that contain inner_content. 
  # These are usually layouts, but components that contain children are basically the same thing
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

    assert result ==
             ~s{<div class="font-bold">Hello, world</div><%= Phoenix.View.render_layout Temple.Components.Component, :self, [] do %><aside class="foobar">I'm a component!</aside><% end %>}

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

    assert result ==
             ~s{<div class="font-bold">Hello, world</div><%= Phoenix.View.render_layout Temple.Components.Component2, :self, [class: "bg-red"] do %>I'm a component!<% end %>}

    assert evaluate_template(result) ==
             ~s{<div class="font-bold">Hello, world</div><div class="bg-red">I'm a component!</div>}
  end

  test "function components can accept local assigns that are variables" do
    result =
      temple do
        div class: "font-bold" do
          "Hello, world"
        end

        class = "bg-red"

        c Temple.Components.Component2, class: class do
          "I'm a component!"
        end
      end

    assert result ==
             ~s{<div class="font-bold">Hello, world</div><% class = "bg-red" %><%= Phoenix.View.render_layout Temple.Components.Component2, :self, [class: class] do %>I'm a component!<% end %>}
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

    assert result ==
             ~s{<%= Phoenix.View.render_layout Temple.Components.Outer, :self, [] do %>outer!\n<% end %><%= Phoenix.View.render_layout Temple.Components.Inner, :self, [outer_id: "set by root inner"] do %>inner!\n<% end %>}

    assert evaluate_template(result) == ~s"""
           <div id="inner" outer-id="from-outer">outer!</div>
           <div id="inner" outer-id="set by root inner">inner!</div>
           """
  end

  test "normal functions with blocks should be treated like if expressions" do
    result =
      temple do
        leenk to: "/route", class: "foo" do
          div class: "hi"
        end
      end

    assert result ==
             ~s{<%= leenk(to: "/route", class: "foo") do %><div class="hi"></div><% end %>}
  end

  test "components can use functions from their modules" do
    result =
      temple do
        c Temple.Components.WithFuncs, foo: :bar do
          "doo doo"
        end
      end

    assert result ==
             ~s{<%= Phoenix.View.render_layout Temple.Components.WithFuncs, :self, [foo: :bar] do %>doo doo<% end %>}

    assert evaluate_template(result) == ~s{<div class="barbarbar">doo doo</div>}
  end

  test "components can be void elements" do
    result =
      temple do
        c Temple.Components.VoidComponent, foo: :bar
      end

    assert result ==
             ~s{<%= Phoenix.View.render Temple.Components.VoidComponent, :self, [foo: :bar] %>}

    assert evaluate_template(result) == ~s{<div class="void!!">bar</div>}
  end
end
