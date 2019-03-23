defmodule FollowThrough.Repo.Migrations.RemoveUniqueConstraintFromGithubUid do
  use Ecto.Migration

  def change do
    drop index(:users, [:github_uid], name: "users_github_uid_index")
  end
end
