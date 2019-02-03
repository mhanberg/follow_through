defmodule FollowThrough.Repo.Migrations.AddInviteCodeColumnToTeamsTable do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :invite_code, :string, null: false
    end

    create unique_index(:teams, :invite_code)
  end
end
