defmodule CsvWriter do
  defstruct(
    filename: nil,
    headers: [],
    rows: [],
    col_len: 0,
    row_len: 0
  )

  # ? rename to new??
  def new(filename) do
    File.open!(filename, [:exclusive]) |> File.close
    %CsvWriter{filename: filename}
  end

  # ? rename to new??
  def new(filename, list_of_headers) when is_list(list_of_headers) do
    File.open!(filename, [:write, :exclusive])
    |> IO.write(list_of_headers |> format_row())

    %CsvWriter{
      filename: filename,
      headers: list_of_headers,
      col_len: list_of_headers |> length,
    }
  end

  def open_file(filename) do
    stream = File.stream!(filename)
    [headers | rows] = for i <- stream, do: i |> String.trim() |> String.split(",")

    header_atoms =  # Turns headers into atoms for keylist
      Enum.map(
        headers,
        fn header ->
          header |> String.to_atom()
        end
      )

    rows =  # Turns rows into keylist with headers as keys
      for row <- rows,
          do:
            List.zip([
              header_atoms,
              row
            ])

    %CsvWriter{
      filename: filename,
      headers: headers,
      rows: rows,
      row_len: rows |> length,
      col_len: headers |> length,
    }
  end

  def write_file(rows, filename) do
    [filename | _ext] = filename |> String.split(".")
    file = "#{filename}.csv" |> File.open!([:write, :exclusive])
    rows
    |> rows_to_strings()
    |> Enum.each(fn row -> write_row(file, row) end)
  end

  def write_file(csv) when is_struct(csv) do
    [filename | _ext] = csv.filename |> String.split(".")
    file = "#{filename}.csv" |> File.open!([:write, :exclusive])
    [csv.headers | csv.rows]
    |> rows_to_strings()
    |> Enum.each(fn row -> write_row(file, row) end)
    csv
  end

  # def modify_headers(csv, list_of_headers) when is_list(list_of_headers) do
  #   # TODO
  #   csv
  #   |> Map.put(:headers, list_of_headers)
  #   |> Map.put(:col_len, list_of_headers |> length)
  # end

  def add_row(csv, row) when is_list(row) do
    with :ok <- validate_row(csv, row),
        _row <- format_row(row) do
      csv
      |> Map.put(:row_len, csv.row_len + 1)
      |> Map.put(:rows, csv.rows ++ row)
    else
      {:error, msg} ->
        IO.inspect(msg, label: "Error occurred")
        csv
    end
  end

  def add_row(csv, row) when not is_list(row) do
    "Row must be a list" |> IO.inspect(label: "Error occurred")
    csv
  end

  # def add_column(csv, col_name, default_value = "") do
  #   # TODO: add column and optional defaul value
  #   # for all rows
  #   123
  # end

  # def replace_values(csv, ) do
  # end
  # TODO: find-and-replace ability

  def filter_rows(csv, field, value) do
    filtered_rows =
      csv.rows
      |> Enum.filter(fn row -> row[field] == value end)
    [csv.headers | filtered_rows]
  end

  defp rows_to_strings(rows) when is_list(rows) do
    rows |> Enum.map(fn row -> row |> format_row end)
  end

  # def update_row(
  #       csv,
  #       field,
  #       value
  #       # update_field,
  #       # update_value
  #     ) do
  #   # TODO:
  #   # filter csv.rows to find value in column
  #   # filtered_rows =
  #   csv
  #   |> filter_rows(field,value)

  #   # get index of row
  #   # |> Enum.with_index()

  #   # delete that intry
  #   # insert row back at same index(if possible)
  # end

  # *************************************** #
  # ********** Private Functions ********** #
  # *************************************** #

  defp validate_row(csv, row) do
    if csv.col_len == row |> length do
      :ok
    else
      {
        :error,
        "Row length does not match CSV column length(#{csv.col_len})"
      }
    end
  end

  defp format_row(row) do
    row =
      with true <- Keyword.keyword?(row) do
        row |> Keyword.values()
      else
        false -> row
      end

    (row |> Enum.join(",")) <> "\n"
  end

  defp write_row(file, row) when is_binary(row) do
    with :ok <- file |> IO.write(row) do
      {:ok, row}
    else
      {:error, reason} -> IO.puts(reason)
    end
  end

end
