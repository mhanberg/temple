defmodule Temple.Parser.MatchTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.Match

  describe "applicable?/1" do
    test "returns true when the node is an elixir match expression" do
      ast =
        quote do
          bingo = Foo.bar!(baz)
        end

      assert Match.applicable?(ast)
    end

    test "returns false when the node is a anything other than an elixir match expression" do
      for node <- [
            :atom,
            %{key: :value},
            []
          ] do
        refute Match.applicable?(node)
      end
    end
  end

  describe "run/2" do
    test "adds a elixir expression node to the buffer" do
      expression =
        quote do
          bingo = Foo.bar!(baz)
        end

      ast = Match.run(expression)

      assert %Temple.Ast{
               meta: %{type: :match},
               content: expression,
               children: []
             } == ast
    end
  end
end
