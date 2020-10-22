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
      |> format_row()
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
    # TODO
    csv =
      csv
      |> Map.put(:headers, list_of_headers)
      |> Map.put(:col_len, list_of_headers |> length)

    {csv, file}
  end

  def add_row({csv, file}, row) do
    with :ok <- validate_row({csv, row}),
         row <- format_row(row) do
      csv = {csv, file, row} |> write_row()

      csv = csv |> Map.put(:row_len, csv.row_len + 1)
      {csv, file}
    else
      {:error, msg} ->
        IO.inspect(msg, label: "Error occurred")
        {csv, file}
    end
  end

  # Private functions

  defp validate_row({csv, row}) do
    if csv.col_len == row |> length do
      :ok
    else
      {:error, "Row length does not match CSV column length(#{csv.col_len})"}
    end
  end

  defp format_row(row) do
    string_row =
      row
      |> Enum.join(",")

    row = string_row <> "\n"
    row
  end

  defp write_row({csv, file, row}) do
    file |> IO.write(row)
    csv
  end

  # defp write_file({csv, file}) do
  #   {csv, file}
  # end
end
