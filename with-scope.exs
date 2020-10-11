content = "Now is the time"

lp =
  with {:ok, file} = File.open("/etc/passwd"),
  content = IO.read(file, :all),
  :ok = File.close(file),
  [_, uid, gid] <- Regex.run(~r/^_lp:.*?:(\d+):(\d+)/m, content)
  do
    "Group: #{gid}, User: #{uid}"
  end

IO.puts lp
IO.puts content


result =
  with {:ok, file} = File.open("/etc/passwd"),
  content = IO.read(file, :all),
  :ok = File.close(file),
  [_, uid, gid] <- Regex.run(~r/^xxx:.*?:(\d+):(\d+)/, content)
  do
    "Group: #{gid}, User: #{uid}"
  end

IO.puts inspect(result)


handle_open = fn
  {:ok, file} -> "Read data: #{IO.read(file, :line)}"
  {_, error} -> "Error: #{:file.format_error(error)}"
end
