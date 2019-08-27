defmodule Temple.LinkTest do
  use ExUnit.Case, async: true
  use Temple

  describe "phx_link" do
    test "emits a link" do
      {:safe, actual} =
        temple do
          phx_link("hi", to: "/hello")
        end

      assert actual =~ ~s{<a}
      assert actual =~ ~s{href="/hello"}
      assert actual =~ ~s{hi}
    end

    test "emits a link when passed block that has text" do
      {:safe, actual} =
        temple do
          phx_link to: "/hello" do
            text "hi"
          end
        end

      assert String.starts_with?(actual, ~s{<a})
      assert actual =~ ~s{href="/hello"}
      assert actual =~ ~s{hi}
      assert String.ends_with?(actual, ~s{</a>})
    end

    test "emits a link when passed block that has more markup" do
      {:safe, actual} =
        temple do
          phx_link to: "/hello" do
            div do
              div "hi"
            end
          end
        end

      assert String.starts_with?(actual, ~s{<a})
      assert actual =~ ~s{href="/hello"}
      assert actual =~ ~s{<div><div>}
      assert actual =~ ~s{hi}
      assert actual =~ ~s{</div></div>}
      assert String.ends_with?(actual, ~s{</a>})
    end

    test "emits a link with additional html attributes" do
      {:safe, actual} =
        temple do
          phx_link("hi",
            to: "/hello",
            class: "phoenix",
            id: "legendary",
            data: [confirm: "Really?"],
            method: :delete
          )
        end

      assert actual =~ ~s{<a}
      assert actual =~ ~s{href="/hello"}
      assert actual =~ ~s{class="phoenix"}
      assert actual =~ ~s{id="legendary"}
      assert actual =~ ~s{data-confirm="Really?"}
      assert actual =~ ~s{hi}
    end

    test "emits a link with a non GET method" do
      {:safe, actual} =
        temple do
          phx_link("hi",
            to: "/hello",
            method: :delete
          )
        end

      assert actual =~ ~s{<a}
      assert actual =~ ~s{data-csrf="}
      assert actual =~ ~s{data-method="delete"}
      assert actual =~ ~s{data-to="/hello"}
      assert actual =~ ~s{hi}
    end
  end

  describe "phx_button" do
    test "emits a button" do
      {:safe, actual} =
        temple do
          phx_button("hi", to: "/hello")
        end

      assert actual =~ ~s{<button}
      assert actual =~ ~s{data-to="/hello"}
      assert actual =~ ~s{data-method="post"}
      assert actual =~ ~s{hi}
    end

    test "emits a button when passed block that has text" do
      {:safe, actual} =
        temple do
          phx_button to: "/hello" do
            text "hi"
          end
        end

      assert String.starts_with?(actual, ~s{<button})
      assert actual =~ ~s{hi}
      assert actual =~ ~s{data-to="/hello"}
      assert actual =~ ~s{data-method="post"}
      assert String.ends_with?(actual, ~s{</button>})
    end

    test "emits a button when passed block that has more markup" do
      {:safe, actual} =
        temple do
          phx_button to: "/hello" do
            div do
              div "hi"
            end
          end
        end

      assert String.starts_with?(actual, ~s{<button})
      assert actual =~ ~s{data-to="/hello"}
      assert actual =~ ~s{data-method="post"}
      assert actual =~ ~s{<div><div>}
      assert actual =~ ~s{hi}
      assert actual =~ ~s{</div></div>}
      assert String.ends_with?(actual, ~s{</button>})
    end

    test "emits a button with additional html attributes" do
      {:safe, actual} =
        temple do
          phx_button("hi",
            to: "/hello",
            class: "phoenix",
            id: "legendary",
            data: [confirm: "Really?"],
            method: :delete
          )
        end

      assert String.starts_with?(actual, ~s{<button})
      assert actual =~ ~s{class="phoenix"}
      assert actual =~ ~s{id="legendary"}
      assert actual =~ ~s{data-confirm="Really?"}
      assert actual =~ ~s{hi}
      assert String.ends_with?(actual, ~s{</button>})
    end

    test "emits a button with a non GET method" do
      {:safe, actual} =
        temple do
          phx_button("hi",
            to: "/hello",
            method: :delete
          )
        end

      assert String.starts_with?(actual, ~s{<button})
      assert actual =~ ~s{data-csrf="}
      assert actual =~ ~s{data-method="delete"}
      assert actual =~ ~s{data-to="/hello"}
      assert actual =~ ~s{hi}
      assert String.ends_with?(actual, ~s{</button>})
    end
  end
end
