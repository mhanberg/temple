defmodule Temple.Ast.ComponentsTest do
  use ExUnit.Case, async: true
  alias Temple.Ast.Components
  alias Temple.Ast.Slottable

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
               arguments: []
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
               arguments: [foo: :bar]
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
               arguments: [foo: :bar]
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
               arguments: [foo: :bar]
             } = ast
    end

    test "gathers all slots", %{func: func} do
      raw_ast =
        quote do
          c unquote(func), foo: :bar do
            slot :foo, let!: %{form: form} do
              "in the slot"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               arguments: [foo: :bar],
               slots: [
                 %Slottable{
                   name: :foo,
                   content: [%Temple.Ast.Text{}],
                   parameter: {:%{}, _, [form: _]}
                 }
               ]
             } = ast
    end

    test "slot attributes", %{func: func} do
      raw_ast =
        quote do
          c unquote(func), foo: :bar do
            slot :foo, let!: %{form: form}, label: the_label do
              "in the slot"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               arguments: [foo: :bar],
               slots: [
                 %Slottable{
                   name: :foo,
                   content: [%Temple.Ast.Text{}],
                   parameter: {:%{}, _, [form: _]},
                   attributes: [label: {:the_label, [], Temple.Ast.ComponentsTest}]
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

                slot :foo, let!: %{text: text, url: url} do
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
               %Slottable{
                 name: :inner_block,
                 parameter: nil
               }
             ] = ast.slots

      assert %Components{
               slots: [
                 %Slottable{
                   content: [
                     %Components{
                       slots: [
                         %Slottable{
                           content: [
                             %Components{
                               slots: [
                                 %Slottable{
                                   name: :inner_block
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

    test "can use let! with default slot without manually declaring it", %{func: func} do
      raw_ast =
        quote do
          c unquote(func), let!: %{form: form}, foo: :bar do
            "in the #{form} inner block"
          end
        end

      ast = Components.run(raw_ast)

      assert %Components{
               function: ^func,
               arguments: [foo: :bar],
               slots: [
                 %Slottable{
                   name: :inner_block,
                   content: [
                     %Temple.Ast.Default{
                       elixir_ast:
                         {:<<>>,
                          [
                            end_of_expression: [newlines: 1, line: 224, column: 41],
                            delimiter: "\""
                          ],
                          [
                            "in the ",
                            {:"::", [],
                             [
                               {{:., [], [Kernel, :to_string]},
                                [from_interpolation: true, closing: [line: 224, column: 27]],
                                [{:form, [], Temple.Ast.ComponentsTest}]},
                               {:binary, [], Temple.Ast.ComponentsTest}
                             ]},
                            " inner block"
                          ]}
                     }
                   ],
                   parameter: {:%{}, _, [form: _]},
                   attributes: []
                 }
               ]
             } = ast
    end
  end
end
