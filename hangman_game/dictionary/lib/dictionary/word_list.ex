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
    # Test supervisor, fail 1/3 times
    # if :rand.uniform() < 0.33 do
    #   Agent.get(@mod, fn _ -> exit(:boom) end)
    # end

    Agent.get(@mod, &Enum.random/1)
  end

  def word_list do
    "../../assets/words.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split("\n")
  end
end
