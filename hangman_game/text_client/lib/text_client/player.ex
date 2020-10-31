defmodule TextClient.Player do
  alias TextClient.{Mover, Prompter, State, Summary,}

  # won, lost, good guess, bad guess, already_used, initialising
  def play(%State{tally: %{ game_state: :won }}) do
    "You Won!" |> exit_with_message
  end

  def play(%State{tally: %{ game_state: :lost }}) do
    "Sorry, You Lost" |> exit_with_message
  end

  def play(game = %State{tally: %{ game_state: :good_guess }}) do
    continue_with_message(game, "Good Guess!")
  end

  def play(game = %State{tally: %{ game_state: :bad_guess }}) do
    continue_with_message(game, "Sorry, that isn't in the word")
  end

  def play(game = %State{tally: %{ game_state: :already_used }}) do
    continue_with_message(game, "You've already guessed that letter")
  end

  def play(game) do
    continue(game)
  end

  def continue_with_message(game, msg) do
    msg |> IO.puts
    continue(game)
  end

  def continue(game) do
    game
    |> Summary.display()
    |> Prompter.accept_move()
    |> Mover.make_move()
    |> play
  end

  defp exit_with_message(msg) do
    msg |> IO.puts
    exit(:normal)
  end
end
