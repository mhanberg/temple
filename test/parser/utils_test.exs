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
end
