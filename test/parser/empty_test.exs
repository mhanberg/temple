defmodule Temple.Parser.EmptyTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.Empty

  describe "applicable?/1" do
    test "returns true when the node is non-content" do
      assert Empty.applicable?(nil)
      assert Empty.applicable?([])
    end

    test "returns fals when the node is a anything other than a string literal" do
      for node <- [
            "string",
            :atom,
            %{key: :value},
            {:ast?, [], []}
          ] do
        refute Empty.applicable?(node)
      end
    end
  end

  describe "run/2" do
    test "adds an empty node to the buffer" do
      for _ <- [nil, []] do
        ast = Empty.run(nil)

        assert %Empty{} == ast
      end
    end
  end
end
