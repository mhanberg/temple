defmodule TempleTest do
  use ExUnit.Case, async: true
  import Temple

  describe "temple/1" do
    test "works" do
      assigns = %{name: "mitch"}

      result =
        temple do
          div class: "hello" do
            div class: "hi" do
              @name
            end
          end
        end

      # heex
      expected = """
      <div class="hello">
        <div class="hi">
          mitch
        </div>

      </div>

      """

      assert expected == result
    end
  end
end
