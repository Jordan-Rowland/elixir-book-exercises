defmodule TodoList do
  defstruct(
    auto_id: 1,
    entries: %{}
  )

  def new(entries \\ []) do
    entries
    |> Enum.reduce(
      %TodoList{},
      fn entry, acc -> add_entry() end
    )
  end
end
