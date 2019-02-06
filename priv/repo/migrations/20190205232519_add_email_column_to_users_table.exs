defmodule FollowThrough.Repo.Migrations.AddEmailColumnToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string, null: false
    end
  end
end
