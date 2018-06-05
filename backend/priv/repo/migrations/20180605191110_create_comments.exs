defmodule Commies.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change() do
    create table(:comments) do
      add :content, :text, null: false
      add :link_id, :string, null: false

      timestamps()
    end

    create index(:comments, [:link_id], using: :hash)
  end
end
