defmodule CsvWriter do
  defstruct(
    filename: nil,
    headers: [],
    rows: [],
    col_len: 0,
    row_len: 0
  )

  def create_file(filename) do
    file = File.open!(filename, [:write, :exclusive])

    {%CsvWriter{
       filename: filename
     }, file}
  end

  def create_file(filename, list_of_headers) when is_list(list_of_headers) do
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
    file = File.open!(filename, [:read, :write])

    stream = File.stream!(filename)
    [headers | rows] = for i <- stream, do: i |> String.trim() |> String.split(",")

    header_atoms =
      Enum.map(
        headers,
        fn header ->
          header |> String.to_existing_atom()
        end
      )

    rows =
      for row <- rows,
          do:
            List.zip([
              header_atoms,
              row
            ])

    csv = %CsvWriter{
      filename: filename,
      headers: headers,
      rows: rows,
      row_len: rows |> length,
      col_len: headers |> length
    }

    {csv, file}
  end

  def modify_headers({csv, file}, list_of_headers) when is_list(list_of_headers) do
    # TODO
    csv =
      csv
      |> Map.put(:headers, list_of_headers)
      |> Map.put(:col_len, list_of_headers |> length)

    {csv, file}
  end

  def add_row({csv, file}, row) when is_list(row) do
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

  def add_row({csv, file}, row) when not is_list(row) do
    msg = "Row must be a list"
    msg |> IO.inspect(label: "Error occurred")
    {csv, file}
  end

  # # TODO
  # def find_rows({csv, file}, column, search_query) do
  #   #
  #   123
  #   # return struct with subset of rows that match search
  #   # CsvWriter%{}
  # end

  # *************************************** #
  # ********** Private Functions ********** #
  # *************************************** #

  defp validate_row({csv, row}) do
    if csv.col_len == row |> length do
      :ok
    else
      {:error, "Row length does not match CSV column length(#{csv.col_len})"}
    end
  end

  defp format_row(row) do
    row =
      with true <- Keyword.keyword?(row) do
        for {_k, v} <- row, do: v
      else
        false -> row
      end

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
