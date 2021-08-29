defmodule Temple.WhitespaceTest do
  use ExUnit.Case, async: true

  import Temple

  test "only emits a single new line" do
    result =
      temple do
        div class: "hello" do
          span id: "foo" do
            "Howdy, "
          end

          div class: "hi" do
            "Jim Bob"
          end

          c WhoaNelly, foo: "bar" do
            slot :silver do
              "esketit"
            end
          end
        end
      end

    assert result ==
             ~s"""
             <div class="hello">
               <span id="foo">
                 Howdy, 
               </span>
               <div class="hi">
                 Jim Bob
               </div>
               <%= Temple.Component.__component__ WhoaNelly, [foo: "bar"] do %>
                 <% {:silver, %{}} -> %>
                   esketit
               <% end %>
             </div>
             """
  end
end
