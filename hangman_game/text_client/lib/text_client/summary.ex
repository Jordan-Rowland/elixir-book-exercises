defmodule TextClient.Summary do

  def display(game = %{ tally: tally }) do
    [
      "\n",
      "Word so far: #{Enum.join(tally.letters, " ")}\n",
      "Guesses left: #{tally.turns_left}\n",
      "Letters guessed: #{Enum.join(tally.guessed, " ")}\n"
    ]
    |> IO.puts
    game
  end
end
