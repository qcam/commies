use Mix.Config

config :commies, Commies.Auth.Github,
  http_client: Commies.HTTP.StandardClient

config :commies, Commies.RouteHelper, base: "http://commies-sg.hqc.me"

import_config "prod.secret.exs"
