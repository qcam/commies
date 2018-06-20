Application.load(:commies)

:commies
|> Application.spec(:applications)
|> Enum.each(&Application.ensure_all_started/1)

:commies
|> Application.fetch_env!(:ecto_repos)
|> Enum.each(&Mix.Ecto.ensure_started(&1, []))

Ecto.Adapters.SQL.Sandbox.mode(Commies.Repo, :manual)

ExUnit.start()
