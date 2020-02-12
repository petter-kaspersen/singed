# Singed - Concurrent, minimal rate limiter for the Riot Games API

Singed allows you to proxy your Riot Games API requests through it, rate limiting them in the process.
This allows you to ensure you respect rate limits, while also getting blazing fast response times from the Riot Games API.


## Examples

```
iex>Singed.start(:euw, %{:rp10s => 500, :rp10m => 30_000})
  {:ok, #PID<>}


iex>Singed.add_request_by_method(:euw, "summoner/name")
  #PID<>
```


