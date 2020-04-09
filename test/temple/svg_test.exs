defmodule Temple.SvgTest do
  use ExUnit.Case, async: true
  import Temple
  import Temple.Utils, only: [to_valid_tag: 1]
  use Temple.Support.Utils

  for tag <- Temple.Svg.elements() -- [:text_] do
    test "renders a #{tag}" do
      {:safe, result} =
        temple do
          unquote(tag)()
        end

      assert result == ~s{<#{to_valid_tag(unquote(tag))}></#{to_valid_tag(unquote(tag))}>}
    end

    test "renders a #{tag} with attrs" do
      {:safe, result} =
        temple do
          unquote(tag)(class: "hello")
        end

      assert result ==
               ~s{<#{to_valid_tag(unquote(tag))} class="hello"></#{to_valid_tag(unquote(tag))}>}
    end

    test "renders a #{tag} with content" do
      {:safe, result} =
        temple do
          unquote(tag)("Hi")
        end

      assert result == "<#{to_valid_tag(unquote(tag))}>Hi</#{to_valid_tag(unquote(tag))}>"
    end

    test "renders a #{tag} with escaped content" do
      {:safe, result} =
        temple do
          unquote(tag)("<div>1</div>")
        end

      assert result ==
               "<#{to_valid_tag(unquote(tag))}>&lt;div&gt;1&lt;/div&gt;</#{
                 to_valid_tag(unquote(tag))
               }>"
    end

    test "renders a #{tag} with attrs and content" do
      {:safe, result} =
        temple do
          unquote(tag)("Hi", class: "hello")
        end

      assert result ==
               ~s{<#{to_valid_tag(unquote(tag))} class="hello">Hi</#{to_valid_tag(unquote(tag))}>}
    end

    test "renders a #{tag} with a block" do
      {:safe, result} =
        temple do
          unquote(tag)(do: unquote(tag)())
        end

      assert result ==
               ~s{<#{to_valid_tag(unquote(tag))}><#{to_valid_tag(unquote(tag))}></#{
                 to_valid_tag(unquote(tag))
               }></#{to_valid_tag(unquote(tag))}>}
    end

    test "renders a #{tag} with attrs and a block" do
      {:safe, result} =
        temple do
          unquote(tag)(class: "hello") do
            unquote(tag)()
          end
        end

      assert result ==
               ~s{<#{to_valid_tag(unquote(tag))} class="hello"><#{to_valid_tag(unquote(tag))}></#{
                 to_valid_tag(unquote(tag))
               }></#{to_valid_tag(unquote(tag))}>}
    end
  end

  test "renders a text" do
    {:safe, result} =
      temple do
        text_()
      end

    assert result == ~s{<text></text>}
  end

  test "renders a text with attrs" do
    {:safe, result} =
      temple do
        text_(class: "hello")
      end

    assert result == ~s{<text class="hello"></text>}
  end

  test "renders a text with content" do
    {:safe, result} =
      temple do
        text_("Hi")
      end

    assert result == "<text>Hi</text>"
  end

  test "renders a text with escaped content" do
    {:safe, result} =
      temple do
        text_("<div>1</div>")
      end

    assert result == "<text>&lt;div&gt;1&lt;/div&gt;</text>"
  end

  test "renders a text with attrs and content" do
    {:safe, result} =
      temple do
        text_("Hi", class: "hello")
      end

    assert result == ~s{<text class="hello">Hi</text>}
  end

  test "renders a text with a block" do
    {:safe, result} =
      temple do
        text_(do: text_())
      end

    assert result == ~s{<text><text></text></text>}
  end

  test "renders a text with attrs and a block" do
    {:safe, result} =
      temple do
        text_(class: "hello") do
          text_()
        end
      end

    assert result ==
             ~s{<text class="hello"><text></text></text>}
  end
end
