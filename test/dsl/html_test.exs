defmodule Dsl.HtmlTest do
  use ExUnit.Case, async: true
  use Dsl

  describe "non-void elements" do
    test "renders two divs" do
      result =
        htm do
          div()
          div()
        end

      assert result == "<div></div><div></div>"
    end

    test "renders two els in the right order" do
      result =
        htm do
          div()
          span()
        end

      assert result == "<div></div><span></span>"
    end

    test "renders two divs that are rendered by a loop" do
      result =
        htm do
          for _ <- 1..2 do
            div()
          end
        end

      assert result == "<div></div><div></div>"
    end

    test "renders two spans" do
      result =
        htm do
          span()
          span()
        end

      assert result == "<span></span><span></span>"
    end

    test "renders a div within a div" do
      result =
        htm do
          div do
            div()
          end
        end

      assert result == "<div><div></div></div>"
    end

    test "renders an attribute on a div" do
      result =
        htm do
          div class: "hello" do
            div(class: "hi")
          end
        end

      assert result == ~s{<div class="hello"><div class="hi"></div></div>}
    end

    test "renders multiple attributes on a div without block" do
      result =
        htm do
          div(class: "hello", id: "12")
        end

      assert result == ~s{<div class="hello" id="12"></div>}
    end
  end

  describe "void elements" do
    test "renders an input" do
      result =
        htm do
          input()
        end

      assert result == ~s{<input>}
    end

    test "renders an input with an attribute" do
      result =
        htm do
          input(type: "number")
        end

      assert result == ~s{<input type="number">}
    end
  end

  describe "escaping" do
    test "marks as safe" do
      {safe?, result} =
        htm safe: true do
          div()
        end

      assert safe? == :safe
      assert IO.iodata_to_binary(result) == ~s{&lt;div&gt;&lt;/div&gt;}
    end
  end

  describe "data attributes" do
    test "can have one data attributes" do
      result =
        htm do
          div(data_controller: "stimulus-controller")
        end

      assert result == ~s{<div data-controller="stimulus-controller"></div>}
    end

    test "can have multiple data attributes" do
      result =
        htm do
          div(data_controller: "stimulus-controller", data_target: "stimulus-target")
        end

      assert result ==
               ~s{<div data-controller="stimulus-controller" data-target="stimulus-target"></div>}
    end
  end

  defmodule CustomTag do
    deftag :flex do
      div(class: "flex")
    end
  end

  describe "custom tags" do
    test "defines a basic tag that acts as partial" do
      import CustomTag

      result =
        htm do
          flex()
        end

      assert result == ~s{<div class="flex"></div>}
    end

    test "defines a tag that takes children" do
      import CustomTag

      result =
        htm do
          flex do
            div()
            div()
          end
        end

      assert result == ~s{<div class="flex"><div></div><div></div></div>}
    end

    test "defines a tag that has attributes" do
      import CustomTag

      result =
        htm do
          flex(class: "justify-between", id: "king")
        end

      assert result =~ ~s{class="flex justify-between"}
      assert result =~ ~s{id="king"}
    end

    test "defines a tag that has attributes AND children" do
      import CustomTag

      result =
        htm do
          flex class: "justify-between" do
            div()
            div()
          end
        end

      assert result == ~s{<div class="flex justify-between"><div></div><div></div></div>}
    end
  end
end
