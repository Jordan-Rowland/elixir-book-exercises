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
      assert ^game = Game.make_move(game, "x")  # Pins the value of 'game' asserting a match
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
    |> Enum.reduce(game, fn ({guess, state}, game) ->  # game is initial accumulator value
      game = Game.make_move(game, guess)
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

    moves = [
      {"x", :bad_guess},
      {"q", :bad_guess},
      {"y", :bad_guess},
      {"r", :bad_guess},
      {"t", :bad_guess},
      {"z", :bad_guess},
      {"m", :lost},
    ]

    moves

    |> Enum.reduce(game, fn ({guess, state}, game) ->  # game is initial accumulator value
      game = Game.make_move(game, guess)
      assert game.game_state == state
      game
    end
    )
  end

  test "guess is validated" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "xx")
    assert game.game_state == :invalid_guess
    game = Game.make_move(game, "w")
    assert game.game_state == :good_guess
  end
end
