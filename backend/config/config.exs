use Mix.Config

config :commies, ecto_repos: [Commies.Repo]

config :commies, Commies.Repo, adapter: Ecto.Adapters.Postgres

import_config "env/#{Mix.env()}.exs"
