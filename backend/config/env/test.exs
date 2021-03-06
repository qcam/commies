use Mix.Config

config :commies, Commies.Repo,
  database: "commies_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :commies, Commies.Auth.Github,
  client_id: "dummy",
  client_secret: "dummy",
  http_client: Commies.HTTP.FakeClient

config :commies, Commies.RouteHelper, base: "http://localhost:3000"

config :commies, Commies.Auth.Token, secret: "longlivetheparty"

config :commies, :frontend, endpoint: "http://localhost:3000"
