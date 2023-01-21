defmodule Temple.Support.Helpers do
  defmacro assert_html(expected, actual) do
    quote do
      assert unquote(expected) == Phoenix.HTML.safe_to_string(unquote(actual)), """
      --- Expected ---
      #{unquote(expected)}----------------

      --- Actual ---
      #{Phoenix.HTML.safe_to_string(unquote(actual))}--------------
      """
    end
  end
end
