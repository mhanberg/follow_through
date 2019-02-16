defmodule FollowThrough.Repo.Migrations.AddSlackIdColumnToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :slack_id, :string
    end
  end
end
