defmodule Procs do
  def greeter(count) do

    receive do
      {:boom, reason} ->
        exit(reason)
      {:add, n} ->
        greeter(count + n)
      {:reset} ->
        greeter(0)
      msg ->
        "#{count}: Hello #{msg}" |> IO.puts()
        greeter(count + 2)
    end
  end

end
