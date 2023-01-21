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
        |> :erlang.iolist_to_binary()

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
end
