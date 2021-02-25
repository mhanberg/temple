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
             ~s{<div class="font-bold">Hello, world</div><%= Phoenix.View.render_layout Temple.Components.Component, :component, [] do %><aside class="foobar">I'm a component!</aside><% end %>}

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
             ~s{<div class="font-bold">Hello, world</div><%= Phoenix.View.render_layout Temple.Components.Component2, :component, [class: "bg-red"] do %>I'm a component!<% end %>}

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
             ~s{<div class="font-bold">Hello, world</div><% class = "bg-red" %><%= Phoenix.View.render_layout Temple.Components.Component2, :component, [class: class] do %>I'm a component!<% end %>}
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
             ~s{<%= Phoenix.View.render_layout Temple.Components.Outer, :component, [] do %>outer!\n<% end %><%= Phoenix.View.render_layout Temple.Components.Inner, :component, [outer_id: "set by root inner"] do %>inner!\n<% end %>}

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
             ~s{<%= Phoenix.View.render_layout Temple.Components.WithFuncs, :component, [foo: :bar] do %>doo doo<% end %>}

    assert evaluate_template(result) == ~s{<div class="barbarbar">doo doo</div>}
  end

  test "components can be void elements" do
    result =
      temple do
        c Temple.Components.VoidComponent, foo: :bar
      end

    assert result ==
             ~s{<%= Phoenix.View.render Temple.Components.VoidComponent, :component, [foo: :bar] %>}

    assert evaluate_template(result) == ~s{<div class="void!!">bar</div>}
  end

  describe "slots" do
    test "basic slots" do
      result =
        temple do
          c Temple.Components.SlotComponent do
            slot :foo, %{this: that} do
              div do
                that
              end
            end

            span do
              "inner content"
            end
          end
        end

      assert result =~
               ~s|<%= Phoenix.View.render_layout Temple.Components.SlotComponent, :component, [slots: %{foo: :"Elixir.Temple.Components.SlotComponent.Foo.|

      assert result =~ ~s|"}] do %><span>inner content</span><% end %>|

      assert evaluate_template(result) ==
               ~s{<section class="foo!"><div>is an assign passed in from slotcomponent</div><span>inner content</span></section>}
    end

    test "component with a slot renders another component that takes a slot" do
      result =
        temple do
          c Temple.Components.SlotWithASlotComponent do
            slot :foo, %{this: that} do
              div do
                that
              end
            end

            span do
              "inner content from slotwithaslot"
            end
          end
        end

      assert result =~
               ~s|<%= Phoenix.View.render_layout Temple.Components.SlotWithASlotComponent, :component, [slots: %{foo: :"Elixir.Temple.Components.SlotWithASlotComponent.Foo.|

      assert result =~ ~s|"}] do %><span>inner content from slotwithaslot</span><% end %>|

      assert evaluate_template(result) ==
               ~s"""
               <section class="foo! from slotwithaslot">
               <div>
               is an assign from the slotwithaslot slot
               </div><section class="foo!">
               <span>
               is an assign passed in from slotcomponent
               </span>
               <span>
               inner content from slot
               </span>
               </section>
               <span>
               inner content from slotwithaslot
               </span>
               </section>
               """
    end
  end
end
