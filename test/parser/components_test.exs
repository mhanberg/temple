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
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          c SomeModule do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Temple.Ast{
               meta: %{type: :component},
               content: SomeModule,
               attrs: [],
               children: _
             } = ast
    end

    test "adds a node to the buffer that takes args" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            aside class: "foobar" do
              "I'm a component!"
            end
          end
        end

      ast = Components.run(raw_ast)

      assert %Temple.Ast{
               meta: %{type: :component},
               content: SomeModule,
               attrs: [foo: :bar],
               children: _
             } = ast
    end
  end
end
