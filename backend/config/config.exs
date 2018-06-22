use Mix.Config

config :commies, ecto_repos: [Commies.Repo]

config :commies, Commies.Repo, adapter: Ecto.Adapters.Postgres

config :logger, :console,
  format: "\n$time $metadata[$level] $message\n",
  metadata: :all

import_config "env/#{Mix.env()}.exs"
