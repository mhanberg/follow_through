defmodule FollowThrough.Repo.Migrations.AddTeamIdReferenceToObligationsTable do
  use Ecto.Migration

  def change do
    alter table(:obligations) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
    end

    create index(:obligations, :team_id)
  end
end
