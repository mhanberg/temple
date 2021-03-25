defmodule Temple.Parser.DoExpressionsTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.DoExpressions

  describe "applicable?/1" do
    test "returns true when the node contains a do expression" do
      raw_ast =
        quote do
          for big <- boys do
            "bob"
          end
        end

      assert DoExpressions.applicable?(raw_ast)
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          for big <- boys do
            "bob"
          end
        end

      ast = DoExpressions.run(raw_ast)

      assert %Temple.Ast{
               meta: %{type: :do_expression},
               content: _,
               children: [
                 [
                   %Temple.Ast{
                     meta: %{type: :text},
                     content: "bob",
                     children: []
                   }
                 ],
                 [
                   %Temple.Ast{
                     meta: %{type: :empty},
                     content: nil,
                     children: []
                   }
                 ]
               ]
             } = ast
    end
  end
end
