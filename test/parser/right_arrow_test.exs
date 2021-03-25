defmodule Temple.Parser.RightArrowTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.RightArrow

  describe "applicable?/1" do
    test "returns true when the node contains a right arrow" do
      [raw_ast] =
        quote do
          :bar ->
            :bang
        end

      assert RightArrow.applicable?(raw_ast)
    end

    test "returns false when the node is anything other than an anonymous function as an argument to a function" do
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
        refute RightArrow.applicable?(raw_ast)
      end
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      [raw_ast] =
        quote do
          :bing ->
            :bong
        end

      bong =
        quote do
          :bong
        end

      ast = RightArrow.run(raw_ast)

      assert %Temple.Ast{
               meta: %{type: :right_arrow},
               content: :bing,
               children: [
                 %Temple.Ast{
                   meta: %{type: :default},
                   content: ^bong,
                   children: []
                 }
               ]
             } = ast
    end
  end
end
