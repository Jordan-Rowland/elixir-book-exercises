defmodule Demo do
  def reverse do
    receive do
      {from_pid, msg} ->
        from_pid |> IO.inspect
        result = msg |> String.reverse
        send from_pid, result
        reverse()
    end
  end
end
