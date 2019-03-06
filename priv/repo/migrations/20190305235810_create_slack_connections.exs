defmodule FollowThrough.Repo.Migrations.CreateSlackConnections do
  use Ecto.Migration

  def change do
    create table(:slack_connections) do
      add :slack_id, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:slack_connections, [:slack_id])
  end
end
