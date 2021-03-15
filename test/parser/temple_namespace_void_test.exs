defmodule Temple.Parser.TempleNamespaceVoidTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.TempleNamespaceVoid

  describe "applicable?/1" do
    test "returns true when the node is a Temple aliased nonvoid element" do
      raw_ast =
        quote do
          Temple.input(name: "bob")
        end

      assert TempleNamespaceVoid.applicable?(raw_ast)
    end

    test "returns false when the node is anything other than a Temple aliased nonvoid element" do
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
        refute TempleNamespaceVoid.applicable?(raw_ast)
      end
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          Temple.meta(class: "foo", id: var)
        end

      ast = TempleNamespaceVoid.run(raw_ast)

      assert %Temple.Ast{
               meta: %{type: :temple_void},
               content: "meta",
               attrs: [class: "foo", id: {:var, [], _}],
               children: []
             } = ast
    end
  end
end
