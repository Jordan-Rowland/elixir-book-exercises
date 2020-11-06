defmodule Fibber do
  # Then create another project for the code that does the Fibonacci calculation. Add the
  # cache as a dependency, and verify that is correctly caches between calls to fib.

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
