defmodule CsvWriter do
  defstruct(
    filename: nil,
    headers: [],
    rows: [],
    col_len: 0,
    row_len: 0
  )

  def new(filename) do
    %CsvWriter{filename: filename}
  end

  def new(filename, list_of_headers) when is_list(list_of_headers) do
    file = File.open!(filename, [:write, :exclusive])
    file |> IO.write(list_of_headers |> format_row())
    file |> File.close()

    %CsvWriter{
      filename: filename,
      headers: list_of_headers,
      col_len: list_of_headers |> length
    }
  end

  def open_file(filename) do
    stream = File.stream!(filename)
    [headers | rows] = for i <- stream, do: i |> String.trim() |> String.split(",")

    # Turns rows into keylist with headers as keys
    rows = zip_to_keyword_list(headers, rows)

    %CsvWriter{
      filename: filename,
      headers: headers,
      rows: rows,
      row_len: rows |> length,
      col_len: headers |> length
    }
  end

  # ? I think this can probably be just 1 function, but not sure.
  # ? This implementation might be too nice.
  def write_file(rows, filename) when is_list(rows) do
    file = filename |> File.open!([:write, :exclusive])

    rows
    |> rows_to_strings()
    |> Enum.each(&write_row(file, &1))

    file |> File.close()
  end

  def write_file(csv, filename) when is_struct(csv) do
    file = filename |> File.open!([:write, :exclusive])

    [csv.headers | csv.rows]
    |> rows_to_strings()
    |> Enum.each(&write_row(file, &1))

    file |> File.close()
  end

  defguard is_valid_headers(csv, list_of_headers)
           when is_list(list_of_headers) and
                  csv.col_len == length(list_of_headers)

  def modify_headers(csv, list_of_headers) when is_valid_headers(csv, list_of_headers) do
    csv
    |> Map.put(:headers, list_of_headers)
    |> Map.put(:col_len, list_of_headers |> length)
    |> update_rows_new_headers(list_of_headers)
  end

  # TODO: Handle error with something better than a print to IO??
  # TODO: Unsure if I want this to fail and crash, or keep running...
  def add_row(csv, row) do
    with true <- row |> is_list(),
         :ok <- validate_row_len(csv, row) do

      case Keyword.keyword?(row) do
        true ->
          csv
          |> Map.put(:row_len, csv.row_len + 1)
          |> Map.put(:rows, csv.rows ++ [row])
        false ->
          csv
          |> Map.put(:row_len, csv.row_len + 1)
          |> Map.put(
              :rows,
              csv.rows ++ zip_to_keyword_list(csv.headers, [row]))
      end

    else
      false ->
        "Row must be a list" |> IO.inspect(label: "Error occurred")
        csv

      {:error, msg} ->
        IO.inspect(msg, label: "Error occurred")
        IO.inspect(row)
        csv
    end
  end

  def add_column(csv, col_name, default_value) do
    csv
    |> Map.put(
      :rows,
      Enum.map(
        csv.rows,
        &(&1 ++ ["#{col_name}": default_value])
      )
    )
    |> Map.put(:headers, csv.headers ++ [col_name])
    |> Map.put(:col_len, csv.headers |> length)
  end

  def add_column(csv, col_name) do
    csv
    |> Map.put(
      :rows,
      Enum.map(
        csv.rows,
        &(&1 ++ ["#{col_name}": ""])
      )
    )
    |> Map.put(:headers, csv.headers ++ [col_name])
    |> Map.put(:col_len, csv.headers |> length)
  end

  def filter_rows(csv, field, value) do
    filtered_rows =
      csv.rows
      |> Enum.filter(&(&1[field] == value))

    [csv.headers | filtered_rows]
  end

  # ? Possilby multiple implementations for row or index passed
  def update_row(csv, old_row, new_row) do
    replace_index =
      csv.rows
      |> Enum.find_index(&(&1 == old_row))

    updated_rows = csv.rows |> List.replace_at(replace_index, new_row)
    Map.put(csv, :rows, updated_rows)
  end

  # ? Possibly have an implementation to pass in a number
  # ? which represents the amount of rows to replace
  def find_replace_all(csv, field, value, replace_value) do
    updated_rows =
      csv
      |> filter_rows(field, value)
      # remove headers
      |> Enum.slice(1..-1)
      |> Enum.reduce(csv.rows, fn row, acc ->
        [
          row
          |> Keyword.replace(field, replace_value)
          | acc
            |> List.delete(row)
        ]
      end)

    csv |> Map.put(:rows, updated_rows)
  end

  # *************************************** #
  # ********** Private Functions ********** #
  # *************************************** #

  defp validate_row_len(csv, row) do
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
      {:error, reason} -> IO.inspect(reason)
    end
  end

  defp convert_headers_to_atoms(list_of_headers) do
    list_of_headers
    |> Enum.map(&(&1 |> String.to_atom()))
  end

  defp update_rows_new_headers(csv, new_headers) do
    csv
    |> Map.put(
      :rows,
      Enum.map(
        csv.rows,
        &List.zip([new_headers |> convert_headers_to_atoms(), Keyword.values(&1)])
      )
    )
  end

  defp rows_to_strings(rows) when is_list(rows) do
    rows |> Enum.map(&(&1 |> format_row))
  end

  defp zip_to_keyword_list(headers, rows) do
    for row <- rows,
        do:
          List.zip([
            headers |> convert_headers_to_atoms(),
            row
          ])
  end
end
