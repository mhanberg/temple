defmodule Temple.Ast.DefaultTest do
  use ExUnit.Case, async: true

  alias Temple.Ast.Default

  describe "applicable?/1" do
    test "returns true when the node is an elixir expression" do
      ast =
        quote do
          Foo.bar!(baz)
        end

      assert Default.applicable?(ast)
    end
  end

  describe "run/2" do
    test "adds a elixir expression node to the buffer" do
      expression =
        quote do
          Foo.bar!(baz)
        end

      ast = Default.run(expression)

      assert %Default{elixir_ast: expression} == ast
    end
  end
end
