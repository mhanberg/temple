defmodule Temple.Parser.TempleNamespaceNonvoidTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.TempleNamespaceNonvoid

  describe "applicable?/1" do
    test "returns true when the node is a Temple aliased nonvoid element" do
      raw_ast =
        quote do
          Temple.div do
            "foo"
          end
        end

      assert TempleNamespaceNonvoid.applicable?(raw_ast)
    end

    test "returns false when the node is anything other than a Temple aliased nonvoid element" do
      raw_asts = [
        quote do
          div do
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
        refute TempleNamespaceNonvoid.applicable?(raw_ast)
      end
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          Temple.div class: "foo", id: var do
            "foo"
          end
        end

      ast = TempleNamespaceNonvoid.run(raw_ast)

      assert %Temple.Ast{
               meta: %{type: :temple_nonvoid},
               content: "div",
               attrs: [class: "foo", id: {:var, [], _}],
               children: [%Temple.Ast{content: "foo"}]
             } = ast
    end
  end
end
