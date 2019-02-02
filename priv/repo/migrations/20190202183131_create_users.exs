defmodule FollowThrough.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :avatar, :string
      add :github_uid, :integer, null: false
      add :remember_me_token, :string

      timestamps()
    end

    create unique_index(:users, [:github_uid])
  end
end
