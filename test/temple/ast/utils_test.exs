defmodule Temple.Ast.UtilsTest do
  use ExUnit.Case, async: true

  alias Temple.Ast.Utils

  describe "compile_attrs/1" do
    test "returns a list of text nodes for static attributes" do
      attrs = [class: "text-red", id: "error", phx_submit: :save, data_number: 99]

      actual = Utils.compile_attrs(attrs)

      assert [
               {:text, ~s' class="text-red"'},
               {:text, ~s' id="error"'},
               {:text, ~s' phx-submit="save"'},
               {:text, ~s' data-number="99"'}
             ] == actual
    end

    test "returns a list of text and expr nodes for attributes with runtime values" do
      class_ast = quote(do: @class)
      attrs = [class: class_ast, id: "foo"]

      assert [{:expr, actual}, {:text, ~s' id="foo"'}] = Utils.compile_attrs(attrs)

      assert Macro.to_string(
               quote do
                 Temple.Ast.Utils.__attributes__([{"class", unquote(class_ast)}])
               end
             ) == Macro.to_string(actual)
    end

    test "the rest! attribute will mix in the values at runtime" do
      rest_ast =
        quote do
          rest
        end

      attrs = [class: "text-red", rest!: rest_ast]

      actual = Utils.compile_attrs(attrs)

      assert [
               {:text, ~s' class="text-red"'},
               {:expr, rest_actual}
             ] = actual

      assert Macro.to_string(
               quote do
                 Temple.Ast.Utils.__attributes__(unquote(rest_ast))
               end
             ) == Macro.to_string(rest_actual)
    end
  end
end
