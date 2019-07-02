defmodule Temple.HtmlTest do
  use ExUnit.Case, async: true
  use Temple

  describe "non-void elements" do
    test "renders two divs" do
      {:safe, result} =
        htm do
          div()
          div()
        end

      assert result == "<div></div><div></div>"
    end

    test "renders two els in the right order" do
      {:safe, result} =
        htm do
          div()
          span()
        end

      assert result == "<div></div><span></span>"
    end

    test "renders an el that taks attrs and a block" do
      {:safe, result} =
        htm do
          div class: "bob" do
            span()
            span()
          end
        end

      assert result == ~s{<div class="bob"><span></span><span></span></div>}
    end

    test "renders one els nested inside an el" do
      {:safe, result} =
        htm do
          div do
            span()
          end
        end

      assert result == "<div><span></span></div>"
    end

    test "renders two els nested inside an el" do
      {:safe, result} =
        htm do
          div do
            span()
            span()
          end
        end

      assert result == "<div><span></span><span></span></div>"
    end

    test "renders two divs that are rendered by a loop" do
      {:safe, result} =
        htm do
          for _ <- 1..2 do
            div()
          end
        end

      assert result == "<div></div><div></div>"
    end

    test "renders two spans" do
      {:safe, result} =
        htm do
          span()
          span()
        end

      assert result == "<span></span><span></span>"
    end

    test "renders a div within a div" do
      {:safe, result} =
        htm do
          div do
            div()
          end
        end

      assert result == "<div><div></div></div>"
    end

    test "renders an attribute on a div" do
      {:safe, result} =
        htm do
          div class: "hello" do
            div class: "hi"
          end
        end

      assert result == ~s{<div class="hello"><div class="hi"></div></div>}
    end

    test "renders an attribute on a div passed as a variable" do
      attrs1 = [class: "hello"]
      attrs2 = [class: "hi"]

      {:safe, result} =
        htm do
          div attrs1 do
            div attrs2
          end
        end

      assert result == ~s{<div class="hello"><div class="hi"></div></div>}
    end

    test "renders multiple attributes on a div without block" do
      {:safe, result} =
        htm do
          div class: "hello", id: "12"
        end

      assert result == ~s{<div class="hello" id="12"></div>}
    end

    test "can accept content as the first argument" do
      {:safe, result} =
        htm do
          div "CONTENT"
          div "MORE", class: "hi"
        end

      assert result == ~s{<div>CONTENT</div><div class="hi">MORE</div>}
    end

    test "can accept content as first argument passed as a variable" do
      content = "CONTENT"
      more = "MORE"

      {:safe, result} =
        htm do
          div content
          div more, class: "hi"
        end

      assert result == ~s{<div>CONTENT</div><div class="hi">MORE</div>}
    end
  end

  describe "void elements" do
    test "renders an input" do
      {:safe, result} =
        htm do
          input()
        end

      assert result == ~s{<input>}
    end

    test "renders an input with an attribute" do
      {:safe, result} =
        htm do
          input type: "number"
        end

      assert result == ~s{<input type="number">}
    end

    test "can use string interpolation in an attribute" do
      interop = "hi"

      {:safe, result} =
        htm do
          div class: "#{interop} world"
        end

      assert result == ~s{<div class="hi world"></div>}
    end
  end

  describe "escaping" do
    test "text is excaped" do
      {:safe, result} =
        htm do
          text "<div>Text</div>"
        end

      assert result == ~s{&lt;div&gt;Text&lt;/div&gt;}
    end
  end

  describe "data attributes" do
    test "can have one data attributes" do
      {:safe, result} =
        htm do
          div data_controller: "stimulus-controller"
        end

      assert result == ~s{<div data-controller="stimulus-controller"></div>}
    end

    test "can have multiple data attributes" do
      {:safe, result} =
        htm do
          div data_controller: "stimulus-controller", data_target: "stimulus-target"
        end

      assert result ==
               ~s{<div data-controller="stimulus-controller" data-target="stimulus-target"></div>}
    end
  end
end
