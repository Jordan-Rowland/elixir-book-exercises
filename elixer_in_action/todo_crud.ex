defmodule TodoList do
  defstruct(
    auto_id: 1,
    entries: %{}
  )

  def new(entries \\ []) do
    entries
    |> Enum.reduce(
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(todo_list = %TodoList{}, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.auto_id,
        entry
      )

    %TodoList{
      todo_list
      | entries: new_entries,
        auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, update_func) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = update_func.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    new_entries =
      todo_list.entries
      |> Enum.filter(fn {_, entry} -> entry.id != entry_id end)

    Map.put(todo_list, :entries, new_entries)
  end
end

defmodule TodoList.CsvImporter do
  def import(filename) do
    File.stream!(filename)
    |> Enum.reduce(
      [],
      fn entry, acc ->
        [date, title] = String.split(entry, ",")
        date = date |> String.replace("/", "-")

        acc ++
          [
            %{
              date: Date.from_iso8601!(date),
              title: String.trim(title)
            }
          ]
      end
    )
    |> TodoList.new()
  end
end
