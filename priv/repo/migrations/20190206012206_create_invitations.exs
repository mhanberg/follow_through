defmodule FollowThrough.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :code, :string
      add :team_id, references(:teams, on_delete: :delete_all)
      add :sender_id, references(:users, on_delete: :delete_all)
      add :invited_email, :string

      timestamps()
    end
  end
end
