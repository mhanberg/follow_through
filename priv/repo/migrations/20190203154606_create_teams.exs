defmodule FollowThrough.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :created_by_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:teams, [:created_by_id])
  end
end
