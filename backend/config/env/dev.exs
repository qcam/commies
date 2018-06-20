use Mix.Config

config :commies, Commies.Repo,
  database: "commies_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commies, Commies.Auth.Github,
  client_id: "19aaaa54f4b9261a6627",
  client_secret: "626a74e223ef386198c65f5bc728f9fb207998e0",
  http_client: Commies.HTTP.StandardClient
