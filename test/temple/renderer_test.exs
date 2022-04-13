defmodule Temple.RendererTest do
  use ExUnit.Case, async: true

  require Temple.Renderer
  alias Temple.Renderer

  describe "compile/1" do
    test "produces renders a text node" do
      result =
        Renderer.compile do
          "hello world"
        end

      assert "hello world\n" == result
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

      assert expected == result
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

      assert expected == result
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

      assert expected == result
    end
  end
end
