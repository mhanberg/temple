defmodule Temple.RendererTest do
  use ExUnit.Case, async: true

  use Temple.Support.Component
  import Temple.Support.Components

  require Temple.Renderer
  alias Temple.Renderer

  import Temple.Support.Helpers

  describe "compile/1" do
    test "produces renders a text node" do
      result =
        Renderer.compile do
          "hello world"
        end

      assert_html "hello world\n", result
    end

    test "produces renders a div" do
      result =
        Renderer.compile do
          div class: "hello world" do
            "hello world"

            span id: "name", do: "bob"
          end
        end

      # html
      expected = """
      <div class="hello world">
        hello world
        <span id="name">bob</span>

      </div>

      """

      assert_html expected, result
    end

    test "produces renders a void elements" do
      result =
        Renderer.compile do
          div class: "hello world" do
            "hello world"

            input type: "button", value: "Submit"
            input type: "button", value: "Submit"
          end
        end

      # html
      expected = """
      <div class="hello world">
        hello world
        <input type="button" value="Submit">
        <input type="button" value="Submit">

      </div>

      """

      assert_html expected, result
    end

    test "foreign void elements get self closing tags" do
      result =
        Renderer.compile do
          input type: "text"
          mprescripts foo: "bar"
          rect width: "256"
          circle cx: "128"
        end

      # html
      expected = """
      <input type="text">
      <mprescripts foo="bar"/>
      <rect width="256"/>
      <circle cx="128"/>
      """

      assert_html expected, result
    end

    test "a match does not emit" do
      result =
        Renderer.compile do
          div class: "hello world" do
            _ = "hello world"

            span id: "name", do: "bob"
          end
        end

      # html
      expected = """
      <div class="hello world">
        <span id="name">bob</span>

      </div>

      """

      assert_html expected, result
    end

    test "handles simple expression inside attributes" do
      assigns = %{statement: "hello world", color: "green"}

      result =
        Renderer.compile do
          div class: @color do
            @statement
          end
        end

      # html
      expected = """
      <div class="green">
        hello world
      </div>

      """

      assert_html expected, result
    end

    test "handles simple expression are the entire attributes" do
      assigns = %{statement: "hello world", attributes: [class: "green"]}

      result =
        Renderer.compile do
          div @attributes do
            @statement
          end
        end

      # html
      expected = """
      <div class="green">
        hello world
      </div>

      """

      assert_html expected, result
    end

    test "handles simple expression with @ assign" do
      assigns = %{statement: "hello world"}

      result =
        Renderer.compile do
          div do
            @statement
          end
        end

      # html
      expected = """
      <div>
        hello world
      </div>

      """

      assert_html expected, result
    end

    test "handles multi line expression" do
      assigns = %{names: ["alice", "bob", "carol"]}

      result =
        Renderer.compile do
          div do
            for name <- @names do
              span class: "name", do: name
            end
          end
        end

      # html
      expected = """
      <div>
        <span class="name">alice</span>
        <span class="name">bob</span>
        <span class="name">carol</span>

      </div>

      """

      assert_html expected, result
    end

    test "if expression" do
      for val <- [true, false] do
        assigns = %{value: val}

        result =
          Renderer.compile do
            div do
              if @value do
                span do: "true"
              else
                span do: "false"
              end
            end
          end

        # html
        expected = """
        <div>
          <span>#{val}</span>

        </div>

        """

        assert_html expected, result
      end
    end

    test "with expression" do
      for val <- [true, false, "bobby"] do
        assigns = %{value: val}

        result =
          Renderer.compile do
            div do
              with false <- @value,
                   true <- "motch" not in ["lame", "not funny"] do
                span do: "false"
              else
                true ->
                  span do: true

                _ ->
                  span do: "bobby"
              end
            end
          end

        # html
        expected = """
        <div>
          <span>#{val}</span>

        </div>

        """

        assert_html expected, result
      end
    end

    test "handles case expression" do
      assigns = %{name: "alice"}

      # html
      expected = """
      <div>
        <span id="correct answer">alice is the best</span>

      </div>

      """

      result =
        Renderer.compile do
          div do
            case @name do
              "bob" ->
                span do: "bob is cool"

              "alice" ->
                span id: "correct answer", do: "alice is the best"

              _ ->
                span do: "everyone is lame"
            end
          end
        end

      assert_html expected, result
    end

    test "handles anonymous functions" do
      assigns = %{names: ["alice", "bob", "carol"]}

      result =
        Renderer.compile do
          div do
            Enum.map(@names, fn name ->
              span class: "name", do: name
            end)
          end
        end

      # html
      expected = """
      <div>
        <span class="name">alice</span>

        <span class="name">bob</span>

        <span class="name">carol</span>


      </div>

      """

      assert_html expected, result
    end

    def super_map(enumerable, func, _extra_args) do
      Enum.map(enumerable, func)
    end

    test "handles anonymous functions with subsequent args" do
      assigns = %{names: ["alice", "bob", "carol"]}

      result =
        Renderer.compile do
          div do
            super_map(
              @names,
              fn name ->
                span class: "name", do: name
              end,
              "hello world"
            )
          end
        end

      # html
      expected = """
      <div>
        <span class="name">alice</span>

        <span class="name">bob</span>

        <span class="name">carol</span>


      </div>

      """

      assert_html expected, result
    end

    test "basic component" do
      result =
        Renderer.compile do
          div do
            c &basic_component/1
          end
        end

      # html
      expected = """
      <div>
      <div>
        I am a basic component
      </div>


      </div>

      """

      assert_html expected, result
    end

    test "component with default slot" do
      assigns = %{}

      result =
        Renderer.compile do
          div do
            c &default_slot/1 do
              span do: "i'm a slot"
            end
          end
        end

      # html
      expected = """
      <div>
      <div>
        I am above the slot
        <span>i'm a slot</span>

      </div>


      </div>

      """

      assert_html expected, result
    end

    test "component with a named slot" do
      assigns = %{label: "i'm a slot attribute"}

      result =
        Renderer.compile do
          div do
            c &named_slot/1, name: "motchy boi" do
              span do: "i'm a slot"

              slot :footer, let!: %{name: name}, label: @label, expr: 1 + 1 do
                p do
                  "#{name}'s in the footer!"
                end
              end
            end
          end
        end

      # heex
      expected = """
      <div>
      <div>
        motchy boi is above the slot
        <span>i'm a slot</span>

      </div>

      <footer>
        <span>i&#39;m a slot attribute</span>
        <p>
          motchy boi&#39;s in the footer!
        </p>

      </footer>


      </div>

      """

      assert_html expected, result
    end
  end

  describe "special attribute stuff" do
    test "class object syntax" do
      result =
        Renderer.compile do
          div class: ["hello world": false, "text-red": true] do
            "hello world"
          end
        end

      # html
      expected = """
      <div class="text-red">
        hello world
      </div>

      """

      assert_html expected, result
    end

    test "boolean attributes only emit correctly with truthy values" do
      result =
        Renderer.compile do
          input type: "text", disabled: true, placeholder: "Enter some text..."
        end

      # html
      expected = """
      <input type="text" disabled placeholder="Enter some text...">
      """

      assert_html expected, result
    end

    test "boolean attributes don't emit with falsy values" do
      result =
        Renderer.compile do
          input type: "text", disabled: false, placeholder: "Enter some text..."
        end

      # html
      expected = """
      <input type="text" placeholder="Enter some text...">
      """

      assert_html expected, result
    end

    test "runtime boolean attributes emit the right values" do
      truthy = true
      falsey = false

      result =
        Renderer.compile do
          input type: "text", disabled: falsey, checked: truthy, placeholder: "Enter some text..."
        end

      # html
      expected = """
      <input type="text" checked placeholder="Enter some text...">
      """

      assert_html expected, result
    end

    test "multiple slots" do
      assigns = %{}

      result =
        Renderer.compile do
          div do
            c &named_slot/1, name: "motchy boi" do
              span do: "i'm a slot"

              slot :footer, let!: %{name: name} do
                p do
                  "#{name}'s in the footer!"
                end
              end

              slot :footer, let!: %{name: name} do
                p do
                  "#{name} is the second footer!"
                end
              end
            end
          end
        end

      # heex
      expected = """
      <div>
      <div>
        motchy boi is above the slot
        <span>i'm a slot</span>

      </div>

      <footer>
        <span></span>
        <p>
          motchy boi&#39;s in the footer!
        </p>
        <span></span>
        <p>
          motchy boi is the second footer!
        </p>

      </footer>


      </div>

      """

      assert_html expected, result
    end

    test "rest! attribute can mix in dynamic attrs with the static attrs" do
      assigns = %{
        rest: [
          class: "font-bold",
          disabled: true
        ]
      }

      result =
        Renderer.compile do
          div id: "foo", rest!: @rest do
            "hi"
          end
        end

      # heex
      expected = """
      <div id="foo" class="font-bold" disabled>
        hi
      </div>

      """

      assert_html expected, result
    end

    test "rest! attribute can mix in dynamic assigns to components" do
      assigns = %{
        rest: [
          class: "font-bold"
        ]
      }

      result =
        Renderer.compile do
          c &rest_component/1, id: "foo", rest!: @rest
        end

      # heex
      expected = """
      <div>
        I am a basic foo with font-bold
      </div>

      """

      assert_html expected, result
    end

    test "rest! attribute can mix in dynamic attributes to slots" do
      assigns = %{
        rest: [
          class: "font-bold"
        ]
      }

      result =
        Renderer.compile do
          c &rest_slot/1 do
            slot :foo,
              id: "passed-into-slot",
              rest!: @rest,
              let!: %{slot_class: class, slot_id: id} do
              "id is #{id} and class is #{class}"
            end
          end
        end

      # heex
      expected = """
      <div>
      id is passed-into-slot and class is font-bold

      </div>

      """

      assert_html expected, result
    end
  end
end
