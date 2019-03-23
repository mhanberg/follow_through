defmodule FollowThrough.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :uid, :string, null: false
      add :provider, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:credentials, [:uid, :provider])
    create index(:credentials, [:user_id])
  end
end
