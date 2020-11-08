defmodule Dictionary.Application do
  use Application

  def start(_type, _args) do
    children = [
      Dictionary.WordList
    ]

    options = [
      name: Dictionary.Supervisor,
      strategy: :one_for_one
      # max_restarts: n,
      # max_seconds: s
      # If more than n restarts occur in a period of s seconds,
      # the supervisor shuts down all its supervised processes
      # and then terminates itself.
    ]

    Supervisor.start_link(children, options)
  end
end
