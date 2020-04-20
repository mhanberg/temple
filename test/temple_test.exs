defmodule TempleTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  test "renders an attribute on a div passed as a variable" do
    result =
      temple do
        div class: "hello" do
          div class: "hi"
        end
      end

    assert result == ~s{<div class="hello"><div class="hi"></div></div>}
  end

  test "renders void element" do
    result =
      temple do
        input name: "password"
      end

    assert result == ~s{<input name="password">}
  end

  test "renders a text node from a literal with siblings" do
    result =
      temple do
        div class: "hello" do
          "hi"
          "foo"
        end
      end

    assert result == ~s{<div class="hello">hifoo</div>}
  end

  test "renders an eval do block as eex" do
    result =
      temple do
        eval do
          x = 1
          y = 2
          z = x + y
          some_function(x, y, z)

          if x == 1 do
            :this
          else
            :that
          end
        end
      end

    assert result ==
             ~s{<% (\n  x = 1\n  y = 2\n  z = x + y\n  some_function(x, y, z)\n  if(x == 1) do\n    :this\n  else\n    :that\n  end\n\n) %>}
  end

  test "renders a variable text node as eex" do
    result =
      temple do
        div class: "hello" do
          foo
        end
      end

    assert result == ~s{<div class="hello"><%= foo %></div>}
  end

  test "renders an assign text node as eex" do
    result =
      temple do
        div class: "hello" do
          @foo
        end
      end

    assert result == ~s{<div class="hello"><%= @foo %></div>}
  end

  test "renders a an expression in attr as eex" do
    result =
      temple do
        div class: foo <> " bar"
      end

    assert result == ~s{<div class="<%= foo <> " bar" %>"></div>}
  end

  test "renders an attribute on a div passed as a variable as eex" do
    result =
      temple do
        div class: Enum.map([:one, :two], fn x -> x end) do
          div class: "hi"
        end
      end

    assert result ==
             ~s{<div class="<%= Enum.map([:one, :two], fn x -> x end) %>"><div class="hi"></div></div>}
  end

  test "renders a for comprehension as eex" do
    result =
      temple do
        for x <- 1..5 do
          div class: "hi"
        end
      end

    assert result == ~s{<%= for(x <- 1..5) do %><div class="hi"></div><% end %>}
  end

  test "renders an if expression as eex" do
    result =
      temple do
        if true == false do
          div class: "hi"
        end
      end

    assert result == ~s{<%= if(true == false) do %><div class="hi"></div><% end %>}
  end

  test "renders an if/else expression as eex" do
    result =
      temple do
        if true == false do
          div class: "hi"
        else
          div class: "haha"
        end
      end

    assert result ==
             ~s{<%= if(true == false) do %><div class="hi"></div><% else %><div class="haha"></div><% end %>}
  end

  test "renders an unless expression as eex" do
    result =
      temple do
        unless true == false do
          div class: "hi"
        end
      end

    assert result == ~s{<%= unless(true == false) do %><div class="hi"></div><% end %>}
  end

  test "renders a function call in eex" do
    result =
      temple do
        div do
          live_render(@conn, Temple.DemoLive)
        end
      end

    assert result == ~s{<div><%= live_render(@conn, Temple.DemoLive) %></div>}
  end

  # test "renders an case expression as eex" do
  #   result =
  #     temple do
  #       case :boom do
  #         :silence ->
  #           div class: "silence"
  #         _ ->
  #           div class: "other"
  #       end
  #     end

  #   assert result == ~s{<%= case(:boom) do %><%= :silence -> %><div class="silence"></div><% _ -> %><div class="other"></div><% end %>}
  # end
end
