defmodule AgentWrapper do

  def new(state) do
    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def update(new_state) do
    Agent.update(__MODULE__, fn _ -> new_state end)
  end
end
