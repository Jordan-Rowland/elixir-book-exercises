defmodule CsvWriterTest do
  use ExUnit.Case
  doctest CsvWriter


  test "opens existing file" do
    # ! TODO: Fix this to account for empty file??
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    filename
    |> File.open()
    |> File.close()

    # csv = filename |> CsvWriter.open_file()
    csv =  # ! This gets deleted
      filename
      |> CsvWriter.create_file()

    csv.file |> File.close()

    assert csv.filename == filename
    filename |> File.rm()
  end


  # # !! TODO: Update this
  # test "opens existing file 2" do
  #   filename = "test.csv"

  #   csv = filename |> CsvWriter.open_file()

  #   # file |> File.close()
  #   filename |> File.rm()
  # end


  test "create file with headers" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.create_file(["id", "name", "address"])

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

    csv =
      filename
      |> CsvWriter.create_file(["id", "name", "address"])
      |> CsvWriter.add_row([1, "djavid", "123 fake st"])
      |> CsvWriter.add_row([2, "jenny", "120 evergreen terrace"])
      |> CsvWriter.add_row([2, "jenny", "120 evergreen terrace", "extra col"])

    assert csv.row_len == 2
    filename |> File.rm()
  end


  test "add row from keyword list" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.create_file(["id", "name", "address"])
      |> CsvWriter.add_row(id: 1, name: "djavid", address: "123 fake st")
      |> CsvWriter.add_row(id: 2, name: "jenny", address: "120 evergreen terrace")

    assert csv.row_len == 2
    filename |> File.rm()
  end


  test "do not allow row longer than column length" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.create_file(["id", "name", "address"])
      |> CsvWriter.add_row([1, "djavid", "123 fake st", "extra_column"])
      |> CsvWriter.add_row(
        id: 2,
        name: "jenny",
        address: "120 evergreen terrace",
        extra: "extra column"
      )

    assert csv.row_len == 0
    filename |> File.rm()
  end


  test "validate row length matches amount of columns" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    row1 = [2, "jenny", "420 high lane"]
    row2 = [2, "jenny", "420 high lane", "extra_column"]

    csv =
      filename
      |> CsvWriter.create_file(["id", "name", "address"])

    assert csv.col_len == row1 |> length
    assert csv.col_len != row2 |> length
    filename |> File.rm()
  end


  test "error on non-list row passed to add_row" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_create_#{dt_now}.csv"

    row = %{this: "fails"}

    csv =
      filename
      |> CsvWriter.create_file(["id", "name", "address"])
      |> CsvWriter.add_row(row)

    assert csv.row_len == 0
    filename |> File.rm()
  end
end
