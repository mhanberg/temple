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

      assert expected == result
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

      assert expected == result
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

      assert expected == result
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

    test "handles case expression" do
      assigns = %{name: "alice"}

      eex_ast =
        EEx.Compiler.compile(
          """
          <div>
            <%= case @name do %>
              <% "bob" -> %>
                <span>bob is cool</span>

              <% "alice" -> %>
                <span>alice is the best</span>

              <% _ -> %>
                <span>everyone is lame</span>
            <% end %>
          </div>
          """,
          parser_options: [token_metadata: true],
          line: 192
        )
        # |> IO.inspect(label: "EEx ast")

      # result =
      #   quote do
      #     div do
      #       case @name do
      #         "bob" ->
      #           span do: "bob is cool"

      #         "alice" ->
      #           span do: "alice is the best"

      #         _ ->
      #           span do: "everyone is lame"
      #       end
      #     end
      #   end
      #   |> Temple.Parser.parse()
      #   |> Temple.Renderer.render()

      # assert eex_ast == result

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

      assert expected == result
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

      assert expected == result
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

      assert expected == result
    end
  end
end
