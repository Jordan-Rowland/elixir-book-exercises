defmodule TextClient.Prompter do

  alias TextClient.State

  def accept_move(game = %State{}) do
    IO.gets("Your guess: ")
    |> check_input(game)
  end

  defp check_input({:error, reason}, _) do
    "Game ended: #{reason}" |> IO.inspect()
    exit(:normal)
  end

  defp check_input(:eof, _) do
    "Looks like you gave up..." |> IO.inspect()
    exit(:normal)
  end

  defp check_input(input, game = %State{}) do
    input = input |> String.trim
    cond do
      input =~ ~r"\A[a-z]\z" ->
        Map.put(game, :guess, input)
      true ->
        "Please enter a single lowercase letter" |> IO.puts
        accept_move(game)
    end
  end
end
