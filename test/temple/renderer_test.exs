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

      expected = """
      <div class="hello world">
        hello world
        <span id="name">bob</span>
      </div>
      """

      assert expected == result
    end
  end
end
