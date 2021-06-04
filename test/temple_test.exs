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

  test "renders a text node from the text keyword with siblings" do
    result =
      temple do
        div class: "hello" do
          "hi"
          "foo"
        end
      end

    assert result == ~s{<div class="hello">hifoo</div>}
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

  test "renders a match expression" do
    result =
      temple do
        x = 420

        div do
          "blaze it"
        end
      end

    assert result == ~s{<% x = 420 %><div>blaze it</div>}
  end

  test "renders a non-match expression" do
    result =
      temple do
        IO.inspect(:foo)

        div do
          "bar"
        end
      end

    assert result == ~s{<%= IO.inspect(:foo) %><div>bar</div>}
  end

  test "renders an expression in attr as eex" do
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

  test "renders a case expression as eex" do
    result =
      temple do
        case @foo do
          :baz ->
            some_component(form: @form)
        end
      end

    expected =
      ~S"""
      <%= case(@foo) do %>
      <% :baz -> %>
      <%= some_component(form: @form) %>
      <% end %>
      """
      |> String.trim()

    assert result == expected
  end

  test "renders multiline anonymous function with 1 arg before the function" do
    result =
      temple do
        form_for Routes.user_path(@conn, :create), fn f ->
          "Name: "
          text_input f, :name
        end
      end

    assert result ==
             ~s{<%= form_for Routes.user_path(@conn, :create), fn f -> %>Name: <%= text_input(f, :name) %><% end %>}
  end

  test "renders multiline anonymous functions with 2 args before the function" do
    result =
      temple do
        form_for @changeset, Routes.user_path(@conn, :create), fn f ->
          "Name: "
          text_input f, :name
        end
      end

    assert result ==
             ~s{<%= form_for @changeset, Routes.user_path(@conn, :create), fn f -> %>Name: <%= text_input(f, :name) %><% end %>}
  end

  test "renders multiline anonymous functions with complex nested children" do
    result =
      temple do
        form_for @changeset, Routes.user_path(@conn, :create), fn f ->
          div do
            "Name: "
            text_input f, :name
          end
        end
      end

    assert result ==
             ~s{<%= form_for @changeset, Routes.user_path(@conn, :create), fn f -> %><div>Name: <%= text_input(f, :name) %></div><% end %>}
  end

  test "renders multiline anonymous function with 3 arg before the function" do
    result =
      temple do
        form_for @changeset, Routes.user_path(@conn, :create), [foo: :bar], fn f ->
          "Name: "
          text_input f, :name
        end
      end

    assert result ==
             ~s{<%= form_for @changeset, Routes.user_path(@conn, :create), [foo: :bar], fn f -> %>Name: <%= text_input(f, :name) %><% end %>}
  end

  test "renders multiline anonymous function with 1 arg before the function and 1 arg after" do
    result =
      temple do
        form_for @changeset,
                 fn f ->
                   "Name: "
                   text_input f, :name
                 end,
                 foo: :bar
      end

    assert result ==
             ~s{<%= form_for @changeset, fn f -> %>Name: <%= text_input(f, :name) %><% end, [foo: :bar] %>}
  end

  test "tags prefixed with Temple. should be interpreted as temple tags" do
    result =
      temple do
        div do
          Temple.span do
            "bob"
          end
        end
      end

    assert result == ~s{<div><span>bob</span></div>}
  end

  test "can pass do as an arg instead of a block" do
    result =
      temple do
        div class: "font-bold" do
          "Hello, world"
        end

        div class: "font-bold", do: "Hello, world"
        div do: "Hello, world"
      end

    assert result ==
             ~s{<div class="font-bold">Hello, world</div><div class="font-bold">Hello, world</div><div>Hello, world</div>}
  end

  test "for with 2 generators" do
    result =
      temple do
        for x <- 1..5, y <- 6..10 do
          div do: x
          div do: y
        end
      end

    assert result ==
             ~s{<%= for(x <- 1..5, y <- 6..10) do %><div><%= x %></div><div><%= y %></div><% end %>}
  end

  test "can pass an expression as assigns" do
    result =
      temple do
        fieldset if true == false, do: [disabled: true], else: [] do
          input type: "text"
        end
      end

    assert result ==
             ~s{<fieldset<%= Temple.Parser.Utils.runtime_attrs(if(true == false) do  [disabled: true]else  []end) %>><input type="text"></fieldset>}
  end

  test "can pass a variable as assigns" do
    result =
      temple do
        fieldset foo_bar do
          input type: "text"
        end
      end

    assert result ==
             ~s{<fieldset<%= Temple.Parser.Utils.runtime_attrs(foo_bar) %>><input type="text"></fieldset>}
  end

  test "can pass a function as assigns" do
    result =
      temple do
        fieldset Foo.foo_bar() do
          input type: "text"
        end
      end

    assert result ==
             ~s{<fieldset<%= Temple.Parser.Utils.runtime_attrs(Foo.foo_bar()) %>><input type="text"></fieldset>}
  end

  test "hr tag works" do
    assigns = %{foo: [class: "foofoo"]}

    result =
      temple do
        div do: "foo"
        hr()
        div do: "foo"
        hr @foo
        div do: "bar"
        hr class: "foofoo"
        div do: "bar"
      end

    assert evaluate_template(result, assigns) ==
             ~s{<div>foo</div><hr><div>foo</div><hr class="foofoo"><div>bar</div><hr class="foofoo"><div>bar</div>}
  end
end
