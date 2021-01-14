defmodule Temple.Parser.ComponentsTest do
  use ExUnit.Case, async: false
  alias Temple.Parser.Components
  use Temple.Support.Utils

  describe "applicable?/1" do
    test "runs when using the `c` ast with a block" do
      ast =
        quote do
          c SomeModule, foo: :bar do
            div do
              "hello"
            end
          end
        end

      assert Components.applicable?(ast)
    end

    test "runs when using the `c` ast without a block" do
      ast =
        quote do
          c(SomeModule, foo: :bar)
        end

      assert Components.applicable?(ast)
    end
  end

  describe "run/2" do
    test "is correct" do
      buf = start_supervised!(Temple.Buffer)

      ast =
        quote do
          c SomeModule, foo: :bar do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      buffers = Temple.Parser.Components.run(ast, %{default: buf}, :default)

      result = Temple.Buffer.get(buffers[:default])

      assert result ==
               ~s{<%= Phoenix.View.render_layout SomeModule, :default, [foo: :bar] do %><aside class="foobar">I'm a component!</aside><% end %>}
    end
  end
end
