defmodule Temple.Parser.AnonymousFunctionsTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.AnonymousFunctions

  describe "applicable?/1" do
    test "returns true when the node contains an anonymous function as an argument to a function" do
      raw_asts = [
        quote do
          form_for(changeset, Routes.foo_path(conn, :create), fn form ->
            Does.something!(form)
          end)
        end
      ]

      for raw_ast <- raw_asts do
        assert AnonymousFunctions.applicable?(raw_ast)
      end
    end

    test "returns false when the node is anything other than an anonymous function as an argument to a function" do
      raw_asts = [
        quote do
          Temple.div do
            "foo"
          end
        end,
        quote do
          link to: "/the/route" do
            "Label"
          end
        end
      ]

      for raw_ast <- raw_asts do
        refute AnonymousFunctions.applicable?(raw_ast)
      end
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      expected_child =
        quote do
          Does.something!(form)
        end

      raw_ast =
        quote do
          form_for(changeset, Routes.foo_path(conn, :create), fn form ->
            unquote(expected_child)
          end)
        end

      ast = AnonymousFunctions.run(raw_ast)

      assert %AnonymousFunctions{
               elixir_ast: _,
               children: [
                 %Temple.Parser.Default{
                   elixir_ast: ^expected_child
                 }
               ]
             } = ast
    end
  end

  describe "Temple.Generator.to_eex/1" do
    test "emits eex" do
      raw_ast =
        quote do
          form_for(changeset, Routes.foo_path(conn, :create), fn form ->
            Does.something!(form)
          end)
        end

      result =
        raw_ast
        |> AnonymousFunctions.run()
        |> struct(children: [])
        |> Temple.Generator.to_eex()

      assert result |> :erlang.iolist_to_binary() ==
               ~s|<%= form_for changeset, Routes.foo_path(conn, :create), fn form -> %>\n<% end %>\n|
    end
  end
end
