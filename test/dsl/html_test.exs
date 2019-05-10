defmodule Dsl.HtmlTest do
  use ExUnit.Case, async: true
  use Dsl

  defmodule Component do
    defcomponent :flex do
      div(class: "flex")
    end

    defcomponent :takes_children do
      div do
        div(id: "static-child-1")
        @children
        div(id: "static-child-2")
      end
    end

    defcomponent :arbitrary_code do
      num = 1..10 |> Enum.reduce(0, fn x, sum -> x + sum end)

      div do
        text(num)
      end
    end

    defcomponent :uses_conditionals do
      if @condition do
        div()
      else
        span()
      end
    end

    defcomponent :arbitrary_data do
      for item <- @lists do
        div do
          text(inspect(item))
        end
      end
    end

    defcomponent :safe do
      div()
    end

    defcomponent :safe_with_prop do
      div id: "safe-with-prop" do
        text(@prop)

        div do
          span do
            for x <- @lists do
              div(do: text(x))
            end
          end
        end
      end
    end

    defcomponent :variable_as_prop do
      div id: @bob
    end

    defcomponent :variable_as_prop_with_block do
      div id: @bob do
        @children
      end
    end
  end

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

  describe "custom component" do
    test "defines a basic component" do
      import Component

      {:safe, result} =
        htm do
          flex()
        end

      assert result == ~s{<div class="flex"></div>}
    end

    test "defines a component that takes 1 child" do
      import Component

      {:safe, result} =
        htm do
          takes_children do
            div id: "dynamic-child"
          end
        end

      assert result ==
               ~s{<div><div id="static-child-1"></div><div id="dynamic-child"></div><div id="static-child-2"></div></div>}
    end

    test "defines a component that takes multiple children" do
      import Component

      {:safe, result} =
        htm do
          takes_children do
            div id: "dynamic-child-1"
            div id: "dynamic-child-2"
          end
        end

      assert result ==
               ~s{<div><div id="static-child-1"></div><div id="dynamic-child-1"></div><div id="dynamic-child-2"></div><div id="static-child-2"></div></div>}
    end

    test "can access a prop" do
      import Component

      {:safe, result} =
        htm do
          takes_children name: "mitch" do
            text @name
          end
        end

      assert result ==
               ~s{<div><div id="static-child-1"></div>mitch<div id="static-child-2"></div></div>}
    end

    test "can have arbitrary code inside the definition" do
      import Component

      {:safe, result} =
        htm do
          arbitrary_code()
        end

      assert result == ~s{<div>55</div>}
    end

    test "can use conditionals to render different markup" do
      import Component

      {:safe, result} =
        htm do
          uses_conditionals(condition: true)
          uses_conditionals(condition: false)
        end

      assert result == ~s{<div></div><span></span>}
    end

    test "can pass arbitrary data as props" do
      import Component

      {:safe, result} =
        htm do
          arbitrary_data(
            lists: [:atom, %{key: "value"}, {:status, :tuple}, "string", 1, [1, 2, 3]]
          )
        end

      assert result ==
               ~s|<div>:atom</div><div>%{key: &quot;value&quot;}</div><div>{:status, :tuple}</div><div>&quot;string&quot;</div><div>1</div><div>[1, 2, 3]</div>|
    end

    test "can pass a variable as a prop" do
      import Component

      bob = "hi"

      {:safe, result} =
        htm do
          variable_as_prop(bob: bob)
        end

      assert result ==
               ~s|<div id="hi"></div>|
    end

    test "can pass a variable as a prop to a component with a block" do
      import Component

      bob = "hi"
      class = "joe"

      {:safe, result} =
        htm do
          variable_as_prop_with_block bob: bob do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div>|
    end

    test "can use string interpolation in props" do
      interop = "hi"

      {:safe, result} =
        htm do
          div class: "#{interop} world"
        end

      assert result == ~s{<div class="hi world"></div>}
    end
  end

  describe "form_for" do
    test "returns a form tag" do
      conn = %Plug.Conn{}
      action = "/"

      {:safe, result} =
        htm do
          form_for(conn, action, [])
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{</form>}
    end

    test "can take a block" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            div()
          end
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{<div></div>}
      assert result =~ ~s{</form>}
    end

    test "can take a block that references the form" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            text_input(form, :bob)
          end
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{<input}
      assert result =~ ~s{type="text"}
      assert result =~ ~s{name="bob"}
      assert result =~ ~s{</form>}
    end
  end
end
