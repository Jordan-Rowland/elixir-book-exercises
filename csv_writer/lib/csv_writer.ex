defmodule CsvWriter do
  defstruct(
    filename: nil,
    headers: [],
    col_len: 0,
    row_len: 0
  )

  def create_file(filename) do
    file = File.open!(filename, [:write, :exclusive])

    {%CsvWriter{
       filename: filename
     }, file}
  end

  def create_file(filename, list_of_headers) do
    file =
      File.open!(filename, [:write, :exclusive])
      |> IO.write(
        list_of_headers
        |> format_row
      )

    {%CsvWriter{
       filename: filename,
       headers: list_of_headers,
       col_len: list_of_headers |> length
     }, file}
  end

  def open_file(filename) do
    file = File.open!(filename, [:write])

    {%CsvWriter{
       filename: filename
     }, file}
  end

  def modify_headers(_file, _list_of_headers) do
    123
  end

  def add_row({csv, file}, )

  # Private functions

  defp format_row(list_of_values) do
    string_row =
      list_of_values
      |> Enum.join(",")

    string_row <> "\n"
  end
end

# """
# {csv, file} = CsvWriter.open_file("test.csv")

# """

# """
# create_file()
# |> add_headers("id", "name", "address")
# |> add_row(1, "djavid", "123 fake st")
# |> add_row(2, "jenny", "420 high lane")
# |> write_file

# # returns file?
# open_file()
# |> find_rows()
# """
