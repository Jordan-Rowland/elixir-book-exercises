defmodule CacheStoreTest do
  use ExUnit.Case
  doctest CacheStore

  test "greets the world" do
    assert CacheStore.hello() == :world
  end
end
