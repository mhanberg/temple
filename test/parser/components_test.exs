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

    test "runs when using the `c` ast with an inline block" do
      ast =
        quote do
          c SomeModule, foo: :bar, do: "hello"
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

      assert %Components{
               module: SomeModule,
               assigns: [],
               children: _
             } = ast
    end

    test "runs when using the `c` ast with an inline block" do
      ast =
        quote do
          c SomeModule, foo: :bar, do: "hello"
        end

      ast = Components.run(ast)

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
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

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
               children: _
             } = ast
    end

    test "adds a node to the buffer that without a block" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar
        end

      ast = Components.run(raw_ast)

      assert %Components{
               module: SomeModule,
               assigns: [foo: :bar],
               children: []
             } = ast
    end
  end

  describe "Temple.Generator.to_eex/1" do
    test "emits eex for non void component" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar do
            "I'm a component!"
          end
        end

      result =
        raw_ast
        |> Components.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s|<%= Phoenix.View.render_layout SomeModule, :self, [foo: :bar] do %>\nI'm a component!\n<% end %>|
    end

    test "emits eex for void component" do
      raw_ast =
        quote do
          c SomeModule, foo: :bar
        end

      result =
        raw_ast
        |> Components.run()
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s|<%= Phoenix.View.render SomeModule, :self, [foo: :bar] %>|
    end
  end
end
