defmodule CsvWriterTest do
  use ExUnit.Case
  doctest CsvWriter

  test "opens existing file" do
    dt_now = DateTime.now!("Etc/UTC")

    filename = "test_create_#{dt_now}.csv"

    filename
    |> File.open()
    |> File.close()

    {csv, file} =
      filename
      |> CsvWriter.open_file()

    file |> File.close()

    assert csv.filename == filename
    filename |> File.rm()
  end

  test "create file with headers" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    {csv, _file} =
      CsvWriter.create_file(
        filename,
        ["id", "name", "address"]
      )

    assert csv.filename == filename
    assert csv.headers == ["id", "name", "address"]
    assert csv.col_len == 3

    [headers | _t] =
      filename
      |> File.read!()
      |> String.split("\n")

    assert headers == "id,name,address"
    filename |> File.rm()
  end

  test "add row to file" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    {csv, _file} =
      CsvWriter.create_file(
        filename,
        ["id", "name", "address"]
      )
      |> CsvWriter.add_row([1, "djavid", "123 fake st"])
      |> CsvWriter.add_row([2, "jenny", "420 high lane"])

    assert csv.row_len == 2
    filename |> File.rm()
  end

  test "modify headers" do
    # TODO
    assert true
  end
end
