defmodule Temple.Parser.UtilsTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.Utils

  describe "runtime_attrs/1" do
    test "compiles keyword lists and maps into html attributes" do
      attrs_map = %{
        class: "text-red",
        id: "form1",
        disabled: false,
        inner_block: %{}
      }

      attrs_kw = [
        class: "text-red",
        id: "form1",
        disabled: true,
        inner_block: %{}
      ]

      assert ~s| class="text-red" id="form1"| == Utils.runtime_attrs(attrs_map)
      assert ~s| class="text-red" id="form1" disabled| == Utils.runtime_attrs(attrs_kw)
    end

    test "class accepts a keyword list which conditionally emits classes" do
      attrs = [class: ["text-red": false, "text-blue": true], id: "form1"]

      assert ~s| class="text-blue" id="form1"| == Utils.runtime_attrs(attrs)
    end
  end

  describe "compile_attrs/1" do
    test "returns a list of text nodes for static attributes" do
      attrs = [class: "text-red", id: "error"]

      actual = Utils.compile_attrs(attrs)

      assert [
               {:text, ~s' class="text-red"'},
               {:text, ~s' id="error"'}
             ] == actual
    end

    test "returns a list of text and expr nodes for attributes with runtime values" do
      class_ast = quote(do: @class)
      id_ast = quote(do: @id)
      attrs = [class: class_ast, id: id_ast, disabled: false, checked: true]

      actual = Utils.compile_attrs(attrs)

      assert [
               {:text, ~s' class="'},
               {:expr, class_ast},
               {:text, ~s'"'},
               {:text, ~s' id="'},
               {:expr, id_ast},
               {:text, ~s'"'},
               {:text, ~s' checked'}
             ] == actual
    end

    test "returns a list of text and expr nodes for the class object syntax" do
      class_ast = quote(do: @class)

      list =
        quote do
          ["text-red": unquote(class_ast)]
        end

      expr =
        quote do
          String.trim_leading(for {class, true} <- unquote(list), into: "", do: " #{class}")
        end

      attrs = [class: ["text-red": class_ast]]

      actual = Utils.compile_attrs(attrs)

      assert [
               {:text, ~s' class="'},
               {:expr, result_expr},
               {:text, ~s'"'}
             ] = actual

      # the ast metadata is different, let's just compare stringified versions
      assert Macro.to_string(result_expr) == Macro.to_string(expr)
    end
  end
end
