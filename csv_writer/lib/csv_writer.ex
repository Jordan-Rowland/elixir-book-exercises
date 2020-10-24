defmodule CsvWriter do
  defstruct(
    filename: nil,
    headers: [],
    rows: [],
    col_len: 0,
    row_len: 0,
    file: nil,
    stream: nil
  )

  def create_file(filename) do
    file = File.open!(filename, [:write, :exclusive])

    %CsvWriter{
      filename: filename,
      file: file
    }
  end

  def create_file(filename, list_of_headers) when is_list(list_of_headers) do
    file = File.open!(filename, [:write, :exclusive])

    file
    |> IO.write(list_of_headers |> format_row())

    %CsvWriter{
      filename: filename,
      headers: list_of_headers,
      col_len: list_of_headers |> length,
      file: file
    }
  end

  def open_file(filename) do
    file = File.open!(filename, [:read, :append])

    stream = File.stream!(filename)
    [headers | rows] = for i <- stream, do: i |> String.trim() |> String.split(",")

    # Turns headers into atoms for keylist
    header_atoms =
      Enum.map(
        headers,
        fn header ->
          header |> String.to_atom()
        end
      )

    # Turns rows into keylist with headers as keys
    rows =
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
      file: file,
      stream: stream
    }
  end

  def modify_headers(csv, list_of_headers) when is_list(list_of_headers) do
    # TODO
    csv
    |> Map.put(:headers, list_of_headers)
    |> Map.put(:col_len, list_of_headers |> length)
  end

  def add_row(csv, row) when is_list(row) do
    with :ok <- validate_row(csv, row),
         row <- format_row(row) do
      csv
      |> write_row(row)
      |> Map.put(:row_len, csv.row_len + 1)
    else
      {:error, msg} ->
        IO.inspect(msg, label: "Error occurred")
        csv
    end
  end

  def add_row(csv, row) when not is_list(row) do
    "Row must be a list"
    |> IO.inspect(label: "Error occurred")

    csv
  end

  def add_column(csv, col_name, default_value = "") do
    # TODO: add column and optional defaul value
    # for all rows
    123
  end

  # def replace_values(csv, )
  # TODO: find-and-replace ability

  # TODO: Decide on implementation of finding rows
  # Might have this function be the filter function
  # from the 'update_row' function below, or might
  # keep this a more complicated and return it's own
  # csv struct.

  # def find_rows(csv, column, search_query) do
  #   #
  #   123
  #   # return struct with subset of rows that match search
  #   # CsvWriter%{}
  # end

  def update_row(
        csv,
        field,
        value
        # update_field,
        # update_value
      ) do
    # TODO:
    # filter csv.rows to find value in column
    # filtered_rows =
    csv.rows
    |> Enum.filter(fn row -> row[field] == value end)
    |> Enum.with_index()

    # get index of row

    # delete that intry
    # insert row back at same index(if possible)
  end

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
        for {_k, v} <- row, do: v
      else
        false -> row
      end

    (row |> Enum.join(",")) <> "\n"
  end

  defp write_row(csv, row) do
    csv.file |> IO.write(row)
    csv
  end

  # defp write_file(csv) do
  #   csv
  # end
end
