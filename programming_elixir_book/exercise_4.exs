fun1 = fn ->
  fn ->
    "Hello"
  end
end

greeter = fn name ->
  fn ->
    "Hello #{name}"
  end
end

prefix = fn prefix ->
  fn name ->
    "#{prefix} #{name}"
  end
end

mrs = prefix.("Mrs.")
IO.puts(mrs.("Smith"))

IO.puts(prefix.("Elixer").("Rocks"))

# Short hand for anonymous functions
add_one = &(&1 + 1)
add_one.(3)
