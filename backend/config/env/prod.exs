use Mix.Config

config :commies, Commies.Auth.Github,
  http_client: Commies.HTTP.StandardClient

import_config "prod.secret.exs"
