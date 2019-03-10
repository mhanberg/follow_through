defmodule FollowThrough.Repo.Migrations.AddTimeZoneColumnToSubscriptionsTable do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add(:timezone, :string)
    end
  end
end
