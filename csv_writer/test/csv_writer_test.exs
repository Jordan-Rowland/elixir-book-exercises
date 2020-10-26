defmodule CsvWriterTest do
  use ExUnit.Case
  doctest CsvWriter

  test "opens existing file" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_1_create_#{dt_now}.csv"

    filename
    |> CsvWriter.new(["header"])
    |> CsvWriter.add_row(["value"])

    csv = filename |> CsvWriter.open_file()

    assert csv.filename == filename
    filename |> File.rm!()
  end

  test "create file with headers" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_2_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.new(["id", "name", "address"])

    assert csv.filename == filename
    assert csv.headers == ["id", "name", "address"]
    assert csv.col_len == 3

    [headers | _t] =
      filename
      |> File.read!()
      |> String.split("\n")

    assert headers == "id,name,address"
    filename |> File.rm!()
  end

  test "add row to file" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_3_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.new(["id", "name", "address"])
      |> CsvWriter.add_row([1, "djavid", "123 fake st"])
      |> CsvWriter.add_row([2, "jenny", "120 evergreen terrace"])
      |> CsvWriter.add_row([2, "jenny", "120 evergreen terrace", "extra col"])

    assert csv.row_len == 2
    filename |> File.rm!()
  end

  test "add row from keyword list" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_4_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.new(["id", "name", "address"])
      |> CsvWriter.add_row(id: 1, name: "djavid", address: "123 fake st")
      |> CsvWriter.add_row(id: 2, name: "jenny", address: "120 evergreen terrace")

    dt_now = DateTime.now!("Etc/UTC")
    filename2 = "test_4_create_#{dt_now}.csv"
    csv |> CsvWriter.write_file(filename2)

    assert csv.row_len == 2
    filename |> File.rm!()
    filename2 |> File.rm!()
  end

  test "do not allow row longer than column length" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_5_create_#{dt_now}.csv"

    csv =
      filename
      |> CsvWriter.new(["id", "name", "address"])
      |> CsvWriter.add_row([1, "djavid", "123 fake st", "extra_column"])
      |> CsvWriter.add_row(
        id: 2,
        name: "jenny",
        address: "120 evergreen terrace",
        extra: "extra column"
      )

    assert csv.row_len == 0
    filename |> File.rm!()
  end

  test "validate row length matches amount of columns" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_6_create_#{dt_now}.csv"

    row1 = [2, "jenny", "420 high lane"]
    row2 = [2, "jenny", "420 high lane", "extra_column"]

    csv =
      filename
      |> CsvWriter.new(["id", "name", "address"])

    assert csv.col_len == row1 |> length
    assert csv.col_len != row2 |> length
    filename |> File.rm!()
  end

  test "error on non-list row passed to add_row" do
    dt_now = DateTime.now!("Etc/UTC")
    filename = "test_7_create_#{dt_now}.csv"

    row = %{this: "fails"}

    csv =
      filename
      |> CsvWriter.new(["id", "name", "address"])
      |> CsvWriter.add_row(row)

    assert csv.row_len == 0
    filename |> File.rm!()
  end

  test "filter rows" do
    csv = %CsvWriter{
      headers: ["id", "name", "age"],
      rows: [
        [id: 2, name: "rick", age: 30],
        [id: 3, name: "dave", age: 33],
        [id: 6, name: "dave", age: 56]
      ]
    }

    [_headers | filtered_rows] =
      csv
      |> CsvWriter.filter_rows(:name, "dave")

    assert filtered_rows |> length() == 2
  end

  test "add column" do
    csv = %CsvWriter{
      headers: ["id", "name", "age"],
      rows: [
        [id: 1, name: "jackson", age: 28]
      ]
    }

    csv1 = csv |> CsvWriter.add_column("address")
    [first_row | _] = csv1.rows
    assert csv1.headers == ["id", "name", "age", "address"]
    assert first_row == [id: 1, name: "jackson", age: 28, address: ""]

    csv2 = csv |> CsvWriter.add_column("address", "123 pike st")
    [first_row | _] = csv2.rows
    assert csv2.headers == ["id", "name", "age", "address"]
    assert first_row == [id: 1, name: "jackson", age: 28, address: "123 pike st"]
  end

  test "modify headers" do
    headers = ["id", "name", "age"]

    csv = %CsvWriter{
      headers: headers,
      col_len: headers |> length,
      rows: [
        [id: 1, name: "jackson", age: 28]
      ]
    }

    new_headers = ["new1", "new2", "new3"]

    csv = csv |> CsvWriter.modify_headers(new_headers)
    [first_row | _] = csv.rows

    assert csv.headers == new_headers
    assert first_row == [new1: 1, new2: "jackson", new3: 28]
  end

  test "update row" do
    csv = %CsvWriter{
      headers: ["id", "name", "age"],
      rows: [
        [id: 1, name: "jackson", age: 28],
        [id: 2, name: "rick", age: 30],
        [id: 3, name: "dave", age: 33],
        [id: 4, name: "mike", age: 55],
        [id: 5, name: "jevin", age: 66],
        [id: 6, name: "dave", age: 56],
        [id: 7, name: "ron", age: 65]
      ]
    }

    old_row = [id: 4, name: "mike", age: 55]
    new_row = [id: 4, name: "michael", age: 56]

    csv = csv |> CsvWriter.update_row(old_row, new_row)

    assert new_row in csv.rows
  end

  test "find and replace" do
    csv = %CsvWriter{
      headers: ["id", "name", "age"],
      rows: [
        [id: 1, name: "jackson", age: 22],
        [id: 2, name: "rick", age: 22],
        [id: 3, name: "dave", age: 22],
        [id: 4, name: "mike", age: 55],
        [id: 5, name: "jevin", age: 66],
        [id: 6, name: "dave", age: 56],
        [id: 7, name: "ron", age: 65]
      ]
    }

    csv |> CsvWriter.find_replace_all(:age, 22, 55)

    csv = csv |> CsvWriter.find_replace_all(:age, 22, 55)

    [updated_row_1 | [updated_row_2 | [updated_row_3 | _tail]]] = csv.rows
    updated_row_1 |> IO.inspect(label: "==>")
    assert updated_row_1 == [id: 1, name: "jackson", age: 55]
    assert updated_row_2 == [id: 2, name: "rick", age: 55]
    assert updated_row_3 == [id: 3, name: "dave", age: 55]

    csv |> IO.inspect(label: "CSV")
  end

  #### ! For testing
  test "testing" do
    csv = %CsvWriter{
      headers: ["id", "name", "age"],
      rows: [
        [id: 1, name: "jackson", age: 28],
        [id: 2, name: "rick", age: 30],
        [id: 3, name: "dave", age: 33],
        [id: 4, name: "mike", age: 55],
        [id: 5, name: "jevin", age: 66],
        [id: 6, name: "dave", age: 56],
        [id: 7, name: "ron", age: 65]
      ]
    }

    [_headers | filtered_rows] =
      csv
      |> CsvWriter.filter_rows(:name, "dave")

    assert filtered_rows |> length() == 2
  end
end
