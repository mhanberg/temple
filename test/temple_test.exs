defmodule TempleTest do
  use ExUnit.Case, async: true
  use Temple

  describe "custom component" do
    test "defcomponent works when requiring the module" do
      require Component, as: C

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
      import Component

      {:safe, result} =
        temple do
          flex()
        end

      assert result == ~s{<div class="flex"></div>}
    end

    test "defines a component that takes 1 child" do
      import Component

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
      import Component

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
      import Component

      {:safe, result} =
        temple do
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
        temple do
          arbitrary_code()
        end

      assert result == ~s{<div>55</div>}
    end

    test "can use conditionals to render different markup" do
      import Component

      {:safe, result} =
        temple do
          uses_conditionals(condition: true)
          uses_conditionals(condition: false)
        end

      assert result == ~s{<div></div><span></span>}
    end

    test "can pass arbitrary data as params" do
      import Component

      {:safe, result} =
        temple do
          takes_params("foo", :bar, 1)
        end

      assert result ==
               ~s{<p>foo</p><p>bar</p><p>1</p>}
    end

    test "can pass a variable as a param" do
      import Component

      num = 3

      {:safe, result} =
        temple do
          takes_params("foo", :bar, num)
        end

      assert result ==
               ~s{<p>foo</p><p>bar</p><p>3</p>}
    end

    test "can pass a variable as a param to a component with a block" do
      import Component

      bob = "hi"

      {:safe, result} =
        temple do
          variable_as_param_with_block bob do
            div()
          end
        end

      assert result == ~s{<div id="hi"><div></div></div>}
    end

    test "can pass arbitrary data as props" do
      import Component

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
      import Component

      bob = "hi"

      {:safe, result} =
        temple do
          variable_as_prop(bob: bob)
        end

      assert result == ~s|<div id="hi"></div>|
    end

    test "can pass a variable as a prop to a component with a block" do
      import Component

      bob = "hi"

      {:safe, result} =
        temple do
          variable_as_prop_with_block bob: bob do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div>|
    end

    test "can pass all of the props as a variable" do
      import Component

      props = [bob: "hi"]

      {:safe, result} =
        temple do
          variable_as_prop(props)
        end

      assert result == ~s|<div id="hi"></div>|
    end

    test "can pass all of the props as a variable with a block" do
      import Component

      props = [bob: "hi"]

      {:safe, result} =
        temple do
          variable_as_prop_with_block props do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div>|
    end

    test "can pass a map as props with a block" do
      import Component

      props = %{bob: "hi"}

      {:safe, result} =
        temple do
          variable_as_prop_with_block props do
            div()
          end

          variable_as_prop_with_block %{bob: "hi"} do
            div()
          end
        end

      assert result == ~s|<div id="hi"><div></div></div><div id="hi"><div></div></div>|
    end

    test "cann pass params and props with a block" do
      import Component

      {:safe, result} =
        temple do
          params_with_props_and_block :bar, prop: :bar do
            span "foo"
          end
        end

      assert result == ~s|<div id="bar"><span>foo</span></div>|
    end

    test "cann pass params and a map as props with a block" do
      import Component

      {:safe, result} =
        temple do
          params_with_props_and_block :baz, %{prop: :baz} do
            span "foo"
          end
        end

      assert result == ~s|<div id="baz"><span>foo</span></div>|
    end
  end
end
