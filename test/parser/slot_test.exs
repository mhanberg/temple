defmodule Temple.Parser.SlotTest do
  use ExUnit.Case, async: false
  alias Temple.Parser.Slot

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

  describe "Temple.Generator.to_eex/1" do
    test "emits eex for a slot" do
      raw_ast =
        quote do
          slot :header, value: Form.form_for(changeset, action)
        end

      result =
        raw_ast
        |> Slot.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s"""
               <%= Temple.Component.__render_block__(@inner_block, {:header, Enum.into([value: Form.form_for(changeset, action)], %{})}) %>
               """
    end
  end
end
