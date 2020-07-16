defmodule PartialTest do
  use ExUnit.Case, async: true
  use Temple
  use Temple.Support.Utils

  test "can correctly redefine elements" do
    result =
      temple do
        section do
          "Howdy!"
        end
      end

    assert result == ~s{<section class="foo!">Howdy!</section>}
  end
end
