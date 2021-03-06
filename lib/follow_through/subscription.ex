defmodule FollowThrough.Subscription do
  use FollowThrough, :schema

  schema "subscriptions" do
    field :channel_id, :string
    field :channel_name, :string
    field :service_team_id, :string
    field :service, :string
    field :delivery_time, :time
    field :timezone, :string

    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :channel_id,
      :channel_name,
      :service_team_id,
      :service,
      :delivery_time,
      :team_id,
      :timezone
    ])
    |> validate_required([
      :channel_id,
      :channel_name,
      :service_team_id,
      :service,
      :timezone,
      :team_id
    ])
    |> unique_constraint(:team_id,
      name: "subscriptions_channel_id_service_team_id_service_team_id_index",
      message: "There is already a subscription for that team"
    )
  end

  @spec get_by(keyword()) :: %__MODULE__{} | nil
  def get_by(attrs) do
    Repo.get_by(__MODULE__, attrs)
  end

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
