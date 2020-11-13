defmodule TodoList.CsvImporter do
  def import(filename) do
    File.stream!(filename)
    |> Enum.reduce(
      %TodoList{},
      fn entry, acc ->
        [date, title] = String.split(entry, ",")
        TodoList.add_entry(acc, %{date: date, title: String.trim(title)})
      end
    )
  end
end
