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
    file = File.open!(filename, [:write, :exclusive])

    file
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

  def modify_headers({csv, file}, list_of_headers) do
    csv =
      csv
      |> Map.put(:headers, list_of_headers)
      |> Map.put(:col_len, list_of_headers |> length)

    {csv, file}
  end

  def add_row({csv, file}, row) do
    string_row = row |> format_row()

    file
    |> IO.write(string_row)

    csv = Map.put(csv, :row_len, csv.row_len + 1)
    {csv, file}
  end

  # Private functions

  defp format_row(list_of_values) do
    string_row =
      list_of_values
      |> Enum.join(",")

    string_row <> "\n"
  end

  defp write_file({csv, file}) do
    {csv, file}
  end

  defp validate_row() do
    true
  end
end

# """
{csv, file} =
  CsvWriter.open_file("test.csv")
  |> CsvWriter.add_row([1, "djavid", "123 fake st"])
  |> CsvWriter.add_row([2, "jenny", "420 high lane"])

# """

# """
# create_file()
# |> add_headers("id", "name", "address")
# |> write_file

# # returns file?
# open_file()
# |> find_rows()
# """
