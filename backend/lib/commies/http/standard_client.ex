defmodule Commies.HTTP.StandardClient do
  @behaviour Commies.HTTP

  def child_spec([]) do
    :hackney_pool.child_spec(:http_pool, timeout: 180_000, max_connections: 100)
  end

  def request(method, url, headers, body, options) do
    :hackney.request(method, url, headers, body, [:with_body, pool: :http_pool] ++ options)
  end
end
