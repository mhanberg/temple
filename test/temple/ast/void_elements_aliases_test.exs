defmodule Temple.Ast.VoidElementsAliasesTest do
  use ExUnit.Case, async: true

  alias Temple.Ast.VoidElementsAliases

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

    test "returns true for an SVG void element alias" do
      raw_ast =
        quote do
          path__(d: "M0 0")
        end

      assert VoidElementsAliases.applicable?(raw_ast)
    end

    test "returns false for the original SVG void name when it has been aliased" do
      raw_ast =
        quote do
          path d: "M0 0"
        end

      refute VoidElementsAliases.applicable?(raw_ast)
    end

    test "returns true for an unaliased MathML void element name" do
      raw_ast =
        quote do
          mprescripts(foo: "bar")
        end

      assert VoidElementsAliases.applicable?(raw_ast)
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
               name: :meta,
               attrs: [content: "foo"]
             } = ast
    end
  end
end
