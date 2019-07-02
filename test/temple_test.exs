defmodule TempleTest do
  use ExUnit.Case, async: true
  use Temple

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

      {:safe, result} =
        htm do
          variable_as_prop_with_block bob: bob do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div>|
    end
  end
end
