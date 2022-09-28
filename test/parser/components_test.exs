defmodule Temple.Parser.ComponentsTest do
  use ExUnit.Case, async: false
  alias Temple.Parser.Components
  alias Temple.Parser.Slottable

  describe "applicable?/1" do
    test "runs when using the `c` ast with a block" do
      ast =
        quote do
          c &SomeModule.render/1, foo: :bar do
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
          c &SomeModule.render/1, foo: :bar do
            "hello"
          end
        end

      assert Components.applicable?(ast)
    end

    test "runs when using the `c` ast without a block" do
      ast =
        quote do
          c &SomeModule.render/1, foo: :bar
        end

      assert Components.applicable?(ast)
    end
  end

  describe "run/2" do
    setup do
      [func: quote(do: &SomeModule.render/1)]
    end

    test "adds a node to the buffer", %{func: func} do
      raw_ast =
        quote do
          c unquote(func) do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               assigns: [],
               children: _
             } = ast
    end

    test "runs when using the `c` ast with an inline block", %{func: func} do
      ast =
        quote do
          c unquote(func), foo: :bar, do: "hello"
        end

      ast = Components.run(ast)

      assert %Components{
               function: ^func,
               assigns: [foo: :bar],
               children: _
             } = ast
    end

    test "adds a node to the buffer that takes args", %{func: func} do
      raw_ast =
        quote do
          c unquote(func), foo: :bar do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               assigns: [foo: :bar],
               children: _
             } = ast
    end

    test "adds a node to the buffer that without a block", %{func: func} do
      raw_ast =
        quote do
          c unquote(func), foo: :bar
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               assigns: [foo: :bar]
             } = ast
    end

    test "gathers all slots", %{func: func} do
      raw_ast =
        quote do
          c unquote(func), foo: :bar do
            slot :foo, %{form: form} do
              "in the slot"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               assigns: [foo: :bar],
               slots: [
                 %Slottable{
                   name: :foo,
                   content: [%Temple.Parser.Text{}],
                   assigns: {:%{}, _, [form: _]}
                 }
               ]
             } = ast
    end

    test "slots should only be assigned to the component root" do
      card = quote do: &Card.render/1
      footer = quote do: &Card.Footer.render/1
      list = quote do: &LinkList.render/1

      raw_ast =
        quote do
          c unquote(card) do
            c unquote(footer) do
              c unquote(list), socials: @user.socials do
                "hello"

                slot :foo, %{text: text, url: url} do
                  a class: "text-blue-500 hover:underline", href: url do
                    text
                  end
                end
              end
            end
          end
        end

      ast = Components.run(raw_ast)

      assert [
               %Temple.Parser.Slottable{
                 name: :default,
                 assigns: {:%{}, [], []}
               }
             ] = ast.slots

      assert %Components{
               slots: [
                 %Temple.Parser.Slottable{
                   content: [
                     %Components{
                       slots: [
                         %Temple.Parser.Slottable{
                           content: [
                             %Components{
                               slots: [
                                 %Slottable{
                                   name: :default
                                 },
                                 %Slottable{
                                   name: :foo
                                 }
                               ]
                             }
                           ]
                         }
                       ]
                     }
                   ]
                 }
               ]
             } = ast
    end
  end
end
