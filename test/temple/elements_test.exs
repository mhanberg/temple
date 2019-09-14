defmodule Temple.ElementsTest do
  use ExUnit.Case, async: true
  import Temple.Elements, only: [defelement: 2]
  import Temple, only: [temple: 1, text: 1]
  import Temple.Html, only: [option: 2]

  defelement(:my_select, :nonvoid)
  defelement(:my_input, :void)

  test "defines a nonvoid element" do
    {:safe, result} =
      temple do
        my_select class: "hello" do
          option "A", value: "A"
          option "B", value: "B"
        end
      end

    assert result ==
             ~s{<my-select class="hello"><option value="A">A</option><option value="B">B</option></my-select>}
  end

  test "defines a void element" do
    {:safe, result} =
      temple do
        my_input(class: "hello")
      end

    assert result == ~s{<my-input class="hello">}
  end
end
