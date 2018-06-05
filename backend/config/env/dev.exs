use Mix.Config

config :commies, Commies.Repo,
  database: "commies_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
