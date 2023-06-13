defmodule Temple.Support.Helpers do
  import ExUnit.Assertions

  defmacro assert_html(expected, actual) do
    quote location: :keep do
      unquote(__MODULE__).__assert_html__(unquote_splicing([expected, actual]))
    end
  end

  def __assert_html__(expected, actual) do
    actual = actual |> Phoenix.HTML.Engine.encode_to_iodata!() |> IO.iodata_to_binary()

    assert expected == actual,
           """
           --- Expected ---
           #{expected}----------------

           --- Actual ---
           #{actual}--------------
           """
  end
end
