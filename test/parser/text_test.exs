defmodule Temple.Parser.TextTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.Text

  describe "applicable?/1" do
    test "returns true when the node is a string literal" do
      assert Text.applicable?("string literal")
    end

    test "returns fals when the node is a anything other than a string literal" do
      for node <- [
            :atom,
            %{key: :value},
            {:ast?, [], []},
            []
          ] do
        refute Text.applicable?(node)
      end
    end
  end

  describe "run/2" do
    test "adds a text node to the buffer" do
      text = "string literal"
      ast = Text.run(text)

      assert %Text{text: text} == ast
    end
  end
end
