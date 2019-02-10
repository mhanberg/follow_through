defmodule FollowThrough.Repo.Migrations.AddCompletedColumnToObligationTable do
  use Ecto.Migration

  def change do
    alter table(:obligations) do
      add :completed, :boolean, default: false, null: false
    end
  end
end
