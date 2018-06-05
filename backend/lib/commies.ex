defmodule Commies do
  use Application

  @port 8000

  def start(_type, _args) do
    children = [
      {Plug.Adapters.Cowboy, scheme: :http, plug: Commies.Router, options: [port: @port]},
      Commies.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
