defmodule Dsl.LinkTest do
  use ExUnit.Case, async: true
  use Dsl

  describe "phx_link" do
    test "emits a link" do
      {:safe, actual} =
        htm do
          phx_link("hi", to: "/hello")
        end

      assert actual =~ ~s{<a}
      assert actual =~ ~s{href="/hello"}
      assert actual =~ ~s{hi}
    end

    test "emits a link when passed block" do
      {:safe, actual} =
        htm do
          phx_link to: "/hello" do
            "hi"
          end
        end

      assert actual =~ ~s{<a}
      assert actual =~ ~s{href="/hello"}
      assert actual =~ ~s{hi}
    end

    test "emits a link with additional html attributes" do
      {:safe, actual} =
        htm do
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
        htm do
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
        htm do
          phx_button("hi", to: "/hello")
        end

      assert actual =~ ~s{<button}
      assert actual =~ ~s{hi}
    end

    test "emits a button when passed block" do
      {:safe, actual} =
        htm do
          phx_button to: "/hello" do
            "hi"
          end
        end

      assert actual =~ ~s{<button}
      assert actual =~ ~s{hi}
    end

    test "emits a button with additional html attributes" do
      {:safe, actual} =
        htm do
          phx_button("hi",
            to: "/hello",
            class: "phoenix",
            id: "legendary",
            data: [confirm: "Really?"],
            method: :delete
          )
        end

      assert actual =~ ~s{<button}
      assert actual =~ ~s{class="phoenix"}
      assert actual =~ ~s{id="legendary"}
      assert actual =~ ~s{data-confirm="Really?"}
      assert actual =~ ~s{hi}
    end

    test "emits a button with a non GET method" do
      {:safe, actual} =
        htm do
          phx_button("hi",
            to: "/hello",
            method: :delete
          )
        end

      assert actual =~ ~s{<button}
      assert actual =~ ~s{data-csrf="}
      assert actual =~ ~s{data-method="delete"}
      assert actual =~ ~s{data-to="/hello"}
      assert actual =~ ~s{hi}
    end
  end
end
