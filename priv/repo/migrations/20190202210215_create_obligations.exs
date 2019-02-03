defmodule FollowThrough.Repo.Migrations.CreateObligations do
  use Ecto.Migration

  def change do
    create table(:obligations) do
      add :description, :text
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
