defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game
  test "new_game returns structure" do
    game = Game.new_game
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters |> length() > 0

    # Assert each char is lowercase and a-z
    lets = for n <- ?a..?z, do: << n :: utf8 >>  # Create an alphabet list, ["a", "b", "c", (...)]
    game.letters |> Enum.map(&(assert &1 in lets))
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game |> Map.put(:game_state, state)
      assert { ^game, _ } = Game.make_move(game, "x")  # Pins the value of 'game' asserting a match
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurence of letter is not already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end
end
