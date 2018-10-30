use Mix.Config

config :commies, Commies.Repo,
  database: "commies_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commies, Commies.Auth.Github,
  client_id: "your-github-client-id",
  client_secret: "your-github-client-secret",
  http_client: Commies.HTTP.StandardClient

config :commies, Commies.Auth.Token, secret: "dummy-auth-token"

config :commies, Commies.RouteHelper, base: "http://localhost:8000"

config :commies, :frontend, endpoint: "http://localhost:3000"

import_config "../{dicon.exs}"
import_config "dev.secret.exs"
