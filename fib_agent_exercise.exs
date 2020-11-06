defmodule FibAgent do
  """
  Rewrite the cache as an application, so that it persists across calls to the Fibonacci
  calculator. This will involve creating a project for it.

  Then create another project for the code that does the Fibonacci calculation. Add the
  cache as a dependency, and verify that is correctly caches between calls to fib.
  """

  def fib(0), do: 0
  def fib(1), do: 1

  def fib(n) do
    case get(n) do
      nil ->
        value = fib(n - 1) + fib(n - 2)
        update(n, value)
        value

      existing_value ->
        existing_value
    end
  end
end
