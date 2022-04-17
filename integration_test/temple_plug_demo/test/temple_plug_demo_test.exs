defmodule TemplePlugDemoTest do
  use ExUnit.Case
  doctest TemplePlugDemo

  test "greets the world" do
    assert TemplePlugDemo.hello() == :world
  end
end
