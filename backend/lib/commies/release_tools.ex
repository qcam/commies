defmodule Commies.ReleaseTools do
  @application Mix.Project.config()[:app]

  def migrate() do
    IO.puts("Booting the application")

    :ok = Application.load(@application)

    Application.ensure_all_started(:ssl)
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:ecto)

    repos = Application.fetch_env!(@application, :ecto_repos)

    IO.puts("Running migrations")

    Enum.each(repos, fn repo ->
      repo.start_link()

      repo_dirname = repo |> Module.split() |> List.last() |> Macro.underscore()
      migrations_path = ["priv", repo_dirname, "migrations"]
      migrations_dir = Application.app_dir(@application, migrations_path)

      Ecto.Migrator.run(repo, migrations_dir, :up, all: true)
    end)

    System.stop()
  end
end
