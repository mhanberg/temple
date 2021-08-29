defmodule Temple.Parser.ComponentsTest do
  use ExUnit.Case, async: false
  alias Temple.Parser.Components
  alias Temple.Parser.Slottable
  use Temple.Support.Utils

  describe "applicable?/1" do
    test "runs when using the `c` ast with a block" do
      ast =
        quote do
          c SomeModule, foo: :bar do
            div do
              "hello"
            end
          end
        end

      assert Components.applicable?(ast)
    end

    test "runs when using the `c` ast with an inline block" do
      ast =
        quote do
          c SomeModule, foo: :bar, do: "hello"
        end

      assert Components.applicable?(ast)
    end

    test "runs when using the `c` ast without a block" do
      ast =
        quote do
          c(SomeModule, foo: :bar)
        end

      assert Components.applicable?(ast)
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          c SomeModule do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               module: SomeModule,
               assigns: [],
               children: _
             } = ast
    end

    test "runs when using the `c` ast with an inline block" do
      ast =
        quote do
          c SomeModule, foo: :bar, do: "hello"
        end

      ast = Components.run(ast)

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
               children: _
             } = ast
    end

    test "adds a node to the buffer that takes args" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
               children: _
             } = ast
    end

    test "adds a node to the buffer that without a block" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar
        end

      ast = Components.run(raw_ast)

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
               children: []
             } = ast
    end

    test "gathers all slots" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            slot :foo, %{form: form} do
              "in the slot"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
               slots: [
                 %Slottable{
                   name: :foo,
                   content: [%Temple.Parser.Text{}],
                   assigns: {:%{}, _, [form: _]}
                 }
               ],
               children: []
             } = ast
    end

    test "slots should only be assigned to the component root" do
      raw_ast =
        quote do
          c Card do
            c Card.Footer do
              c LinkList, socials: @user.socials do
                "hello"

                slot :default, %{text: text, url: url} do
                  a class: "text-blue-500 hover:underline", href: url do
                    text
                  end
                end
              end
            end
          end
        end

      ast = Components.run(raw_ast)

      assert Kernel.==(ast.slots, [])

      assert %Components{
               children: [
                 %Components{
                   children: [
                     %Components{
                       slots: [
                         %Slottable{
                           name: :default
                         }
                       ]
                     }
                   ]
                 }
               ]
             } = ast
    end
  end

  describe "Temple.Generator.to_eex/1" do
    test "emits eex for non void component" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            "I'm a component!"
          end
        end

      result =
        raw_ast
        |> Components.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s"""
               <%= Temple.Component.__component__ SomeModule, [foo: :bar] do %>
                 <% {:default, _} -> %>
                   I'm a component!
               <% end %>
               """
    end

    test "emits eex for void component with slots" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            slot :foo, %{form: form} do
              div do
                "in the slot"
              end
            end
          end
        end

      result =
        raw_ast
        |> Components.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s"""
               <%= Temple.Component.__component__ SomeModule, [foo: :bar] do %>
                 <% {:foo, %{form: form}} -> %>
                   <div>
                     in the slot
                   </div>
               <% end %>
               """
    end

    test "emits eex for nonvoid component with slots" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            slot :foo, %{form: form} do
              div do
                "in the slot"
              end
            end

            div do
              "inner content"
            end
          end
        end

      result =
        raw_ast
        |> Components.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s"""
               <%= Temple.Component.__component__ SomeModule, [foo: :bar] do %>
                 <% {:default, _} -> %>
                   <div>
                     inner content
                   </div>
                 <% {:foo, %{form: form}} -> %>
                   <div>
                     in the slot
                   </div>
               <% end %>
               """
    end

    test "emits eex for void component" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar
        end

      result =
        raw_ast
        |> Components.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s|<%= Temple.Component.__component__ SomeModule, [foo: :bar] %>|
    end
  end
end
