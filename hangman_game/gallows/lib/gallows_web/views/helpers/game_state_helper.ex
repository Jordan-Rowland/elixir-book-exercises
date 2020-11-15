defmodule GallowsWeb.Views.Helpers.GameStateHelpers do
  @responses %{
    :won => {:success, "You Won!"},
    :lost => {:danger, "You Lost!"},
    :good_guess => {:success, "Good guess!"},
    :bad_guess => {:warning, "Bad guess!"},
    :already_used => {:info, "You already guessed that"}
  }

  def game_state(state) do
    @responses[state]
    |> alert()
  end

  defp alert(nil), do: ""

  defp alert({class, message}) do
    {
      :safe,
      """
      <div class="alert alert-#{class}">
      #{message}
      </div>
      """
    }
  end
end
