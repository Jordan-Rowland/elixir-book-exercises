defmodule CacheStore do
  # Rewrite the cache as an application, so that it persists across calls to the Fibonacci
  # calculator. This will involve creating a project for it.

  @mod __MODULE__

  def start_link(initial_state = %{}) do
    Agent.start_link(fn -> initial_state end, name: @mod)
  end

  def state do
    Agent.get(@mod, fn state -> state end)
  end

  def get(n) do
    state()
    |> Map.get(n)
  end

  def update(key, value) do
    Agent.update(@mod, fn state -> Map.put(state, key, value) end)
  end
end
