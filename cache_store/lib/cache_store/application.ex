defmodule CacheStore.Application do
  use Application

  def start(_type, _args) do
    CacheStore.start_link(%{0 => 0, 1 => 1})
  end
end
