defmodule FollowThrough.Repo.Migrations.RemoveGithubUidColumnFromUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :github_uid, :string
    end
  end
end
