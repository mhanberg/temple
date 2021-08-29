defmodule Temple.Parser.DoExpressionsTest do
  use ExUnit.Case, async: true

  alias Temple.Parser.DoExpressions
  alias Temple.Support.Utils

  describe "applicable?/1" do
    test "returns true when the node contains a do expression" do
      raw_ast =
        quote do
          for big <- boys do
            "bob"
          end
        end

      assert DoExpressions.applicable?(raw_ast)
    end
  end

  describe "run/2" do
    test "adds a node to the buffer" do
      raw_ast =
        quote do
          for big <- boys do
            "bob"
          end
        end

      ast = DoExpressions.run(raw_ast)

      assert %DoExpressions{
               elixir_ast: _,
               children: [
                 [%Temple.Parser.Text{text: "bob"}],
                 nil
               ]
             } = ast
    end
  end

  describe "to_eex/1" do
    test "emits eex" do
      result =
        quote do
          for big <- boys do
            "bob"
          end
        end
        |> DoExpressions.run()
        |> Temple.Generator.to_eex()
        |> Utils.iolist_to_binary()

      assert result ==
               ~s"""
               <%= for(big <- boys) do %>
                 bob
               <% end %>
               """
    end

    test "emits eex for that includes in else clause" do
      result =
        quote do
          if foo? do
            "bob"

            "bobby"
          else
            "carol"
          end
        end
        |> DoExpressions.run()
        |> Temple.Generator.to_eex()
        |> Utils.iolist_to_binary()

      assert result ==
               ~s"""
               <%= if(foo?) do %>
                 bob
                 bobby
               <% else %>
                 carol
               <% end %>
               """
    end

    test "emits eex for a case expression" do
      result =
        quote do
          case foo? do
            :bing ->
              :bong
          end
        end
        |> DoExpressions.run()
        |> Temple.Generator.to_eex()
        |> Utils.iolist_to_binary()

      assert result ==
               ~s"""
               <%= case(foo?) do %>
                 <% :bing -> %>
                   <%= :bong %>
               <% end %>
               """
    end
  end
end
