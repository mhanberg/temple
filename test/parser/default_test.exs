defmodule Temple.Parser.DefaultTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.Default

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

      assert %Default{
               content: expression,
               children: []
             } == ast
    end
  end

  describe "to_eex/1" do
    test "emits eex" do
      result =
        quote do
          Foo.bar!(baz)
        end
        |> Default.run()
        |> Temple.EEx.to_eex()

      assert result |> :erlang.iolist_to_binary() == ~s|<%= Foo.bar!(baz) %>|
    end
  end
end
