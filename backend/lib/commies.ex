defmodule Commies do
  use Application

  @port 8000

  def start(_type, _args) do
    children = [
      {Plug.Adapters.Cowboy, scheme: :http, plug: Commies.Router, options: [port: @port]},
      :hackney_pool.child_spec(:commies_pool, timeout: 180_000, max_connections: 100),
      Commies.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
