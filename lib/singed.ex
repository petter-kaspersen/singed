defmodule Singed do
  alias Singed.Limiter
  def start(server, %{:rp10s => _, :rp10m => _} = limits) when is_atom(server) do
    Limiter.start(server, limits)
  end

  def add_request_by_method(server, method) do
    current_methods = Limiter.get(server, :methods)

    # First - is this the first time doing a request?

    case current_methods[method] do
      %{rp10s: rp10s, rp10m: rp10m} ->
        Limiter.put(server, :methods, Map.put(current_methods, method, %{rp10s: rp10s + 1, rp10m: rp10m + 1}))
      _ ->
        Limiter.put(server, :methods, Map.put(current_methods, method, %{rp10s: 1, rp10m: 1}))
    end

    decrement_method_timeout(server, method)
  end

  defp decrement_method_timeout(server, method) do
    spawn fn ->
      Process.sleep(30_000) # 30 seconds
      decrement_if_exists(server, method)
    end

    spawn fn ->
      Process.sleep(60_000 * 10) # 10 minutes
      decrement_if_exists(server, method)
    end
  end

  defp decrement_if_exists(server, method) do
    current_methods = Limiter.get(server, :methods)

    case current_methods[method] do
      %{rp10s: rp10s, rp10m: rp10m} ->
        Limiter.put(server, :methods, Map.put(current_methods, method, %{rp10s: rp10s - 1, rp10m: rp10m - 1}))
      _ ->
        nil
    end
  end

  def test() do
    start(:euw, %{:rp10s => 500, :rp10m => 30000})

    add_request_by_method(:euw, "summoner/name")
    add_request_by_method(:euw, "summoner/name")
    add_request_by_method(:euw, "summoner/name")

    Process.sleep(40_000)

    Limiter.get(:euw, :methods)
  end

end
