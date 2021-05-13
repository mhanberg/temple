defmodule Temple.Parser.UtilsTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.Utils

  describe "runtime_attrs/1" do
    test "compiles keyword lists and maps into html attributes" do
      attrs_map = %{
        class: "text-red",
        id: "form1",
        inner_block: %{}
      }

      attrs_kw = [
        class: "text-red",
        id: "form1",
        inner_block: %{}
      ]

      assert {:safe, ~s| class="text-red" id="form1"|} == Utils.runtime_attrs(attrs_map)
      assert {:safe, ~s| class="text-red" id="form1"|} == Utils.runtime_attrs(attrs_kw)
    end
  end
end
