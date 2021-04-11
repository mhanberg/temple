defmodule Temple.Parser.NonvoidElementsAliasesTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.NonvoidElementsAliases

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
               children: [
                 %NonvoidElementsAliases{
                   name: "select",
                   children: [
                     %NonvoidElementsAliases{
                       name: "option",
                       children: [
                         %Temple.Parser.Text{text: "foo"}
                       ]
                     }
                   ]
                 }
               ]
             } = ast
    end
  end

  describe "to_eex/1" do
    test "emits eex" do
      result =
        quote do
          div class: "foo", id: var do
            select__ do
              option do
                "foo"
              end
            end
          end
        end
        |> NonvoidElementsAliases.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s|<div class="foo" id="<%= var %>">\n<select>\n<option>\nfoo\n\n</option>\n</select>\n</div>|
    end
  end
end
