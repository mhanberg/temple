defmodule Dsl.UtilsTest do
  use ExUnit.Case, async: true

  describe "from_safe/1" do
    test "returns a the text from a safe partial" do
      expected = "I am safe!"
      partial = {:safe, expected}

      result = Dsl.Utils.from_safe(partial)

      assert result == expected
    end

    test "escapes an unsafe partial and returns the text" do
      expected = "I am &lt;safe&gt;!"
      partial = "I am <safe>!"

      result = Dsl.Utils.from_safe(partial)

      assert result == expected
    end
  end
end
