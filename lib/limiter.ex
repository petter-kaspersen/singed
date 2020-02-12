defmodule Singed.Limiter do
  use GenServer

  def start(name, limits) when is_atom(name) do
    GenServer.start(Singed.Limiter, %{limits: limits, methods: %{}}, name: name)
  end

  def put(server, key, value) do
    GenServer.cast(server, {:put, key, value})
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end
