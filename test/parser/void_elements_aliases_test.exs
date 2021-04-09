defmodule Temple.Parser.VoidElementsAliasesTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.VoidElementsAliases

  describe "applicable?/1" do
    test "returns true when the node is a nonvoid element or alias" do
      raw_asts = [
        quote do
          link__(src: "example.com/foo")
        end,
        quote do
          meta content: "foo"
        end
      ]

      for raw_ast <- raw_asts do
        assert VoidElementsAliases.applicable?(raw_ast)
      end
    end

    test "returns false when the node is anything other than a nonvoid element or alias" do
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
        refute VoidElementsAliases.applicable?(raw_ast)
      end
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          meta content: "foo"
        end

      ast = VoidElementsAliases.run(raw_ast)

      assert %VoidElementsAliases{
               content: :meta,
               attrs: [content: "foo"],
               children: []
             } = ast
    end
  end

  describe "to_eex/1" do
    test "emits eex" do
      result =
        quote do
          meta content: "foo"
        end
        |> VoidElementsAliases.run()
        |> Temple.EEx.to_eex()

      assert result |> :erlang.iolist_to_binary() == ~s|<meta content="foo">\n|
    end
  end
end
