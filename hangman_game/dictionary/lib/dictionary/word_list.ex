defmodule Dictionary.WordList do
  @mod __MODULE__

  def start_link do
    Agent.start_link(&word_list/0, name: @mod)
  end

  def child_spec(_args) do
    %{
      id: Dictionary.WordList,
      start: {Dictionary.WordList, :start_link, []}
    }
  end

  def random_word do
    Agent.get(@mod, &Enum.random/1)
  end

  def word_list do
    "../../assets/words.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split("\n")
  end
end
