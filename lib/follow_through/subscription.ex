defmodule FollowThrough.Subscription do
  use FollowThrough, :schema

  schema "subscriptions" do
    field :channel_id, :string
    field :channel_name, :string
    field :service_team_id, :string
    field :service, :string
    field :delivery_time, :time

    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :channel_id,
      :channel_name,
      :service_team_id,
      :service,
      :delivery_time,
      :team_id
    ])
    |> validate_required([
      :channel_id,
      :channel_name,
      :service_team_id,
      :service,
      :delivery_time,
      :team_id
    ])
    |> unique_constraint(:team_id,
      name: "subscriptions_channel_id_service_team_id_service_team_id_index",
      message: "There is already a subscription for that team"
    )
  end

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs) do
    case %__MODULE__{}
         |> changeset(attrs)
         |> Repo.insert() do
      {:ok, subscription} ->
        {:ok, subscription}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec delivery_time_in_utc(String.t()) :: String.t()
  def delivery_time_in_utc(timezone) do
    Timex.now(timezone)
    |> Timex.set(time: ~T[10:00:00])
    |> Timex.Timezone.convert("Etc/UTC")
    |> DateTime.to_time()
    |> Time.to_string()
  end
end
