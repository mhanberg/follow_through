defmodule FollowThrough.Repo.Migrations.RemoveInviteCodeFromTeamsTable do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove :invite_code
    end
  end
end
