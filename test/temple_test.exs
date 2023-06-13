defmodule TempleTest do
  use ExUnit.Case, async: true
  import Temple

  describe "temple/1" do
    test "works" do
      assigns = %{name: "mitch", extra: [foo: "bar"]}

      result =
        temple do
          div class: "hello", rest!: [id: "hi", name: @name] do
            div class: "hi", rest!: @extra do
              @name
            end
          end
        end
        |> Phoenix.HTML.safe_to_string()

      # heex
      expected = """
      <div class="hello" id="hi" name="mitch">
        <div class="hi" foo="bar">
          mitch
        </div>

      </div>

      """

      assert expected == result
    end
  end

  describe "attributes/1" do
    test "compiles runtime attributes" do
      assert ~s| disabled class="foo"| == attributes(disabled: true, checked: false, class: "foo")
    end
  end
end
