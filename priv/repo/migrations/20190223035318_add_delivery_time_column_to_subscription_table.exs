defmodule FollowThrough.Repo.Migrations.AddDeliveryTimeColumnToSubscriptionTable do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add(:delivery_time, :time,
        null: false,
        default: ~T[15:00:00.000] |> Time.to_string()
      )
    end
  end
end
