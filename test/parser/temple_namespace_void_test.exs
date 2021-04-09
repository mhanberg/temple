defmodule Temple.Parser.TempleNamespaceVoidTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.TempleNamespaceVoid
  alias Temple.Parser.VoidElementsAliases

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

      assert %VoidElementsAliases{
               content: :meta,
               attrs: [class: "foo", id: {:var, [], _}],
               children: []
             } = ast
    end
  end

  describe "to_eex/1" do
    test "emits eex" do
      result =
        quote do
          Temple.meta(content: "foo")
        end
        |> TempleNamespaceVoid.run()
        |> Temple.EEx.to_eex()

      assert result |> :erlang.iolist_to_binary() == ~s|<meta content="foo">\n|
    end
  end
end
