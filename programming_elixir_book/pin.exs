defmodule Greeter do
  def for(name, greeting) do
    fn
      # This will 'pin' the value of the variable "name"
      # to the match clause
      ^name -> "#{greeting} #{name}"
      _ -> "I don't know you"
    end
  end
end

# "Mr. Anderson" is the value that gets 'pinned'
# to the above function match
mr_anderson = Greeter.for("Mr. Anderson", "Hello,")

IO.puts(mr_anderson.("Mr. Anderson"))
IO.puts(mr_anderson.("Mr. Freemont"))
