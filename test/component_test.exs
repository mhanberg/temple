defmodule Temple.ComponentTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  test "renders components" do
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
             ~s"""
             <div class="font-bold">
               Hello, world
             </div>
             <div>
               
               <aside class="foobar">
                   I'm a component!
                 </aside>

             </div>
             """
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
             ~s"""
             <div class="font-bold">
               Hello, world
             </div>
             <div class="bg-red">

                 I'm a component!

             </div>
             """
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
           <div id="inner" outer-id="from-outer">
             
               
               outer!


           </div>


           <div id="inner" outer-id="set by root inner">
             
               inner!

           </div>

           """
  end

  test "components can use functions from their modules" do
    result =
      temple do
        c Temple.Components.WithFuncs, foo: :bar do
          "doo doo"
        end
      end

    assert evaluate_template(result) == ~s"""
           <div class="barbarbar">

               doo doo

           </div>
           """
  end

  test "components can be void elements" do
    result =
      temple do
        c Temple.Components.VoidComponent, foo: :bar
      end

    assert evaluate_template(result) == ~s"""
           <div class="void!!">
             bar
           </div>
           """
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

      result
      |> IO.puts()

    assert evaluate_template(result, assigns) ==
             ~s"""
             <div>

                 <div>
             the value is Header
                 </div>

               <div class="wrapped">

                 <button class="btn" phx-click="toggle">
             bob
                 </button>
               
               </div>
             </div>

             """

    assert false
  end

  test "new test" do
    use Phoenix.HTML

    ~E"""
    <%= Temple.Component.__component__ Temple.Components.Link, [href: "/home"] do %><% {:default, _} -> %>link text<% {:foo, _} -> %>foo<% end %>
    """
    |> elem(1)
    |> :erlang.iolist_to_binary()
    |> IO.puts()

    # result =
    #   temple do
    #     c Temple.Components.Link, href: "/home" do
    #       "link text"

    #       slot :foo do
    #         "foo"
    #       end
    #     end

    #     a! class: "text-blue-400 hover:underline", href: "/home" do
    #       "link text"
    #     end
    #   end

    # # IO.puts(result)
    # result = result |> evaluate_template()
    # IO.puts(result)
    result = nil

    assert result ==
             """
             <div class="border-4 border-green-500">
               <section>
                 <a class="text-blue-400 hover:underline" href="/">Home</a>
                 <a class="text-blue-400 hover:underline" href="/about">About</a>
                 <a class="text-blue-400 hover:underline" href="/posts">Posts</a>
                 <a class="text-blue-400 hover:underline" href="/jokes">Dad Jokes</a>
                 <a class="text-blue-400 hover:underline" href="/bookshelf">Bookshelf</a>
               </section>

               <div>
                 right side of the panel
               </div>


             </div>
             """

    assert false
  end
end
