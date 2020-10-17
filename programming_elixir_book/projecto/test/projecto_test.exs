defmodule ProjectoTest do
  use ExUnit.Case
  doctest Projecto

  test "greets the world" do
    assert Projecto.hello() == :world
  end
end
