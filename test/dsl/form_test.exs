defmodule Dsl.FormTest do
  use ExUnit.Case, async: true
  use Dsl

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
