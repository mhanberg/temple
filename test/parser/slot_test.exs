defmodule Temple.Ast.SlotTest do
  use ExUnit.Case, async: false
  alias Temple.Ast.Slot

  describe "applicable?/1" do
    test "runs when using the `c` ast with a block" do
      ast =
        quote do
          slot :header, value: "yolo"
        end

      assert Slot.applicable?(ast)
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          slot :header, value: "yolo"
        end

      ast = Slot.run(raw_ast)

      assert %Slot{
               name: :header,
               args: [value: "yolo"]
             } == ast
    end
  end
end
