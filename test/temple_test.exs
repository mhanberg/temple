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

    test "compiles an SVG element alias" do
      assigns = %{}
      _ = assigns

      result =
        temple do
          text__ x: "10", y: "20" do
            "label"
          end
        end
        |> Phoenix.HTML.safe_to_string()

      assert result =~ ~s|<text x="10" y="20">|
      assert result =~ "label"
      assert result =~ "</text>"
    end

    test "compiles an SVG void element alias" do
      assigns = %{}
      _ = assigns

      result =
        temple do
          path__ d: "M0 0"
        end
        |> Phoenix.HTML.safe_to_string()

      assert result =~ ~s|<path d="M0 0"|
      refute result =~ "</path>"
    end

    test "compiles a MathML element alias" do
      assigns = %{}
      _ = assigns

      result =
        temple do
          mtext__ do
            "label"
          end
        end
        |> Phoenix.HTML.safe_to_string()

      assert result =~ "<mtext>"
      assert result =~ "label"
      assert result =~ "</mtext>"
    end
  end

  describe "attributes/1" do
    test "compiles runtime attributes" do
      assert ~s| disabled class="foo"| == attributes(disabled: true, checked: false, class: "foo")
    end
  end
end
