use Mix.Config

config :commies, Commies.Repo,
  database: "commies_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
