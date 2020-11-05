defmodule FibAgent do
  def new do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  def state do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def get(n) do
    Agent.get(__MODULE__, fn state -> state end)
    |> Map.get(n)
  end

  def fib(0), do: 0
  def fib(1), do: 1

  def fib(n) do
    case get(n) do
      nil ->
        Agent.update(__MODULE__, fn state -> Map.put(state, n, n-1 + n-2) end)
        n-1 + n-2
      existing_value -> existing_value
    end
  end

end
