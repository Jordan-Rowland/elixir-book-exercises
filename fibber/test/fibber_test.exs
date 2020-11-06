defmodule FibberTest do
  use ExUnit.Case
  doctest Fibber

  test "greets the world" do
    assert Fibber.hello() == :world
  end
end
