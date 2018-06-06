defmodule Commies.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change() do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :auth_provider, :string, null: false
      add :auth_user_id, :string, null: false

      timestamps()
    end

    create index(:users, [:auth_provider, :auth_user_id], unique: true)
  end
end
