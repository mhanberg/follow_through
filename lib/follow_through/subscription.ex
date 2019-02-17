defmodule FollowThrough.Subscription do
  use FollowThrough, :schema

  schema "subscriptions" do
    field :channel_id, :string
    field :channel_name, :string
    field :service_team_id, :string
    field :service, :string

    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:channel_id, :channel_name, :service_team_id, :service, :team_id])
    |> validate_required([:channel_id, :channel_name, :service_team_id, :service, :team_id])
    |> unique_constraint(:team_id,
      name: "subscriptions_channel_id_service_team_id_service_index",
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
end