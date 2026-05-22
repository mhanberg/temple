defmodule Temple.Ast.NonvoidElementsAliasesTest do
  use ExUnit.Case, async: true

  alias Temple.Ast.NonvoidElementsAliases
  alias Temple.Ast.ElementList
  alias Temple.Ast.Text

  describe "applicable?/1" do
    test "returns true when the node is a nonvoid element or alias" do
      raw_asts = [
        quote do
          div do
            "foo"
          end
        end,
        quote do
          select__ do
            option do
              "Label"
            end
          end
        end
      ]

      for raw_ast <- raw_asts do
        assert NonvoidElementsAliases.applicable?(raw_ast)
      end
    end

    test "returns false when the node is anything other than a nonvoid element or alias" do
      raw_asts = [
        quote do
          Temple.div do
            "foo"
          end
        end,
        quote do
          link to: "/the/route" do
            "Label"
          end
        end
      ]

      for raw_ast <- raw_asts do
        refute NonvoidElementsAliases.applicable?(raw_ast)
      end
    end

    test "returns true for an SVG element alias" do
      raw_ast =
        quote do
          text__ do
            "label"
          end
        end

      assert NonvoidElementsAliases.applicable?(raw_ast)
    end

    test "returns false for the original SVG name when it has been aliased" do
      raw_ast =
        quote do
          text do
            "label"
          end
        end

      refute NonvoidElementsAliases.applicable?(raw_ast)
    end

    test "returns true for a MathML element alias" do
      raw_ast =
        quote do
          mtext__ do
            "label"
          end
        end

      assert NonvoidElementsAliases.applicable?(raw_ast)
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          div class: "foo", id: var do
            select__ do
              option do
                "foo"
              end
            end
          end
        end

      ast = NonvoidElementsAliases.run(raw_ast)

      assert %NonvoidElementsAliases{
               name: "div",
               attrs: [class: "foo", id: {:var, [], _}],
               children: %ElementList{
                 children: [
                   %NonvoidElementsAliases{
                     name: "select",
                     children: %ElementList{
                       children: [
                         %NonvoidElementsAliases{
                           name: "option",
                           children: %ElementList{
                             children: [
                               %Text{text: "foo"}
                             ]
                           }
                         }
                       ]
                     }
                   }
                 ]
               }
             } = ast
    end

    test "uses the configured alias for an SVG element" do
      raw_ast =
        quote do
          text__ x: "10" do
            "label"
          end
        end

      ast = NonvoidElementsAliases.run(raw_ast)

      assert %NonvoidElementsAliases{
               name: "text",
               attrs: [x: "10"],
               children: %ElementList{children: [%Text{text: "label"}]}
             } = ast
    end

    test "uses the configured alias for a MathML element" do
      raw_ast =
        quote do
          mtext__ do
            "label"
          end
        end

      ast = NonvoidElementsAliases.run(raw_ast)

      assert %NonvoidElementsAliases{
               name: "mtext",
               children: %ElementList{children: [%Text{text: "label"}]}
             } = ast
    end
  end
end
