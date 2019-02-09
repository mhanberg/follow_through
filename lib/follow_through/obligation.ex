defmodule FollowThrough.Obligation do
  use FollowThrough, :schema

  schema "obligations" do
    field :description, :string

    belongs_to :user, FollowThrough.User
    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @doc false
  def changeset(obligation, attrs \\ %{}) do
    obligation
    |> cast(attrs, [:description, :user_id, :team_id])
    |> validate_required([:description, :user_id, :team_id])
  end

  def new do
    %__MODULE__{} |> changeset
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def for_user(user_id) do
    __MODULE__
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def for_team(obligations, team_id) do
    Enum.filter(obligations, &(&1.team_id == team_id))
  end
end
