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
      assert game = Game.make_move(game, "x")  # Pins the value of 'game' asserting a match
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurence of letter is not already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")
    assert game.game_state != :already_used
    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    game = Game.new_game("wibble")

    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"l", :good_guess},
      {"e", :won},
    ]

    moves
    |> Enum.reduce(game, fn  # game is initial accumulator value, new_game is arg for that value
      ({guess, state}, game) -> game = Game.make_move(game, guess)
      assert game.game_state == state
      game
    end
    )
  end

  test "a bad guess is recognized" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "lost game is recognized" do
    game = Game.new_game("w")
    game = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
    game = Game.make_move(game, "q")
    assert game.game_state == :bad_guess
    assert game.turns_left == 5
    game = Game.make_move(game, "y")
    assert game.game_state == :bad_guess
    assert game.turns_left == 4
    game = Game.make_move(game, "r")
    assert game.game_state == :bad_guess
    assert game.turns_left == 3
    game = Game.make_move(game, "t")
    assert game.game_state == :bad_guess
    assert game.turns_left == 2
    game = Game.make_move(game, "z")
    assert game.game_state == :bad_guess
    assert game.turns_left == 1
    game = Game.make_move(game, "m")
    assert game.game_state == :lost
  end
end
