use Mix.Config

config :commies, ecto_repos: [Commies.Repo]

config :commies, Commies.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commies_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
