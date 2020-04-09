defmodule TempleTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  describe "custom component" do
    test "defcomponent works when requiring the module" do
      require Temple.Support.Component, as: C

      {:safe, result} =
        temple do
          C.flex()

          C.flex([])
          C.flex([], [])

          C.flex do
            text "hi"
          end
        end

      assert result ==
               ~s{<div class="flex"></div><div class="flex"></div><div class="flex"></div><div class="flex"></div>}
    end

    test "defines a basic component" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          flex()
        end

      assert result == ~s{<div class="flex"></div>}
    end

    test "defines a component that takes 1 child" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          takes_children do
            div id: "dynamic-child"
          end
        end

      assert result ==
               ~s{<div><div id="static-child-1"></div><div id="dynamic-child"></div><div id="static-child-2"></div></div>}
    end

    test "defines a component that takes multiple children" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          takes_children do
            div id: "dynamic-child-1"
            div id: "dynamic-child-2"
          end
        end

      assert result ==
               ~s{<div><div id="static-child-1"></div><div id="dynamic-child-1"></div><div id="dynamic-child-2"></div><div id="static-child-2"></div></div>}
    end

    test "can access a prop" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          takes_children name: "mitch" do
            text @name
          end
        end

      assert result ==
               ~s{<div><div id="static-child-1"></div>mitch<div id="static-child-2"></div></div>}
    end

    test "can access assigns list" do
      import Temple.Support.Component

      assigns = [foo: "bar", hello: "world"]

      {:safe, result} =
        temple do
          lists_assigns(assigns)
        end

      assert result == inspect(assigns)
    end

    test "can access assigns map" do
      import Temple.Support.Component

      assigns = %{foo: "bar", hello: "world"}

      {:safe, result} =
        temple do
          lists_assigns(assigns)
        end

      assert result == inspect(assigns)
    end

    test "can have arbitrary code inside the definition" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          arbitrary_code()
        end

      assert result == ~s{<div>55</div>}
    end

    test "can use conditionals to render different markup" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          uses_conditionals(condition: true)
          uses_conditionals(condition: false)
        end

      assert result == ~s{<div></div><span></span>}
    end

    test "can pass arbitrary data as assigns" do
      import Temple.Support.Component

      {:safe, result} =
        temple do
          arbitrary_data(
            lists: [:atom, %{key: "value"}, {:status, :tuple}, "string", 1, [1, 2, 3]]
          )
        end

      assert result ==
               ~s|<div>:atom</div><div>%{key: &quot;value&quot;}</div><div>{:status, :tuple}</div><div>&quot;string&quot;</div><div>1</div><div>[1, 2, 3]</div>|
    end

    test "can pass a variable as a prop" do
      import Temple.Support.Component

      bob = "hi"

      {:safe, result} =
        temple do
          variable_as_prop(bob: bob)
        end

      assert result == ~s|<div id="hi"></div>|
    end

    test "can pass a variable as a prop to a component with a block" do
      import Temple.Support.Component

      bob = "hi"

      {:safe, result} =
        temple do
          variable_as_prop_with_block bob: bob do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div>|
    end

    test "can pass all of the assigns as a variable" do
      import Temple.Support.Component

      assigns = [bob: "hi"]

      {:safe, result} =
        temple do
          variable_as_prop(assigns)
        end

      assert result == ~s|<div id="hi"></div>|
    end

    test "can pass all of the assigns as a variable with a block" do
      import Temple.Support.Component

      assigns = [bob: "hi"]

      {:safe, result} =
        temple do
          variable_as_prop_with_block assigns do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div>|
    end

    test "can pass a map as assigns with a block" do
      import Temple.Support.Component

      assigns = %{bob: "hi"}

      {:safe, result} =
        temple do
          variable_as_prop_with_block assigns do
            div()
          end

          variable_as_prop_with_block %{bob: "hi"} do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div><div id="hi"><div></div></div>|
    end
  end
end
