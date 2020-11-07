defmodule CacheStore.Application do
  use Application

  def start(_type, _args) do
    CacheStore.start_link(%{})
  end
end
