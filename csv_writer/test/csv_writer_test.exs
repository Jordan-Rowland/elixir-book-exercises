defmodule CsvWriterTest do
  use ExUnit.Case
  doctest CsvWriter

  test "opens existing file" do
    {csv, _file} =
      "test.csv"
      |> CsvWriter.open_file()

    assert csv.filename == "test.csv"
  end

  test "create file with headers" do
    dt_now = DateTime.now!("Etc/UTC")

    {csv, _file} =
      CsvWriter.create_file(
        "test_create_#{dt_now}.csv",
        ["id", "name", "address"]
      )

    assert csv.filename == "test_create_#{dt_now}.csv"
    assert csv.headers == ["id", "name", "address"]
    assert csv.col_len == 3

    [headers | _t] =
      "test_create_#{dt_now}.csv"
      |> File.read!()
      |> String.split("\n")

    assert headers == "id,name,address"
  end
end
