defmodule FollowThrough.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add(:channel_id, :string)
      add(:channel_name, :string)
      add(:service_team_id, :string)
      add(:service, :string)

      add(:team_id, references(:teams, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:subscriptions, [:channel_id, :service_team_id, :service, :team_id]))
  end
end
