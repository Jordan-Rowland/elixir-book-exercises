defmodule Fibber do

  def fib(0), do: 0
  def fib(1), do: 1

  def fib(n) do
    case CacheStore.get(n) do
      nil ->
        value = fib(n - 1) + fib(n - 2)
        CacheStore.update(n, value)
        value

      existing_value ->
        existing_value
    end
  end
end
