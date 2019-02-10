defmodule FollowThrough.Obligation do
  use FollowThrough, :schema

  schema "obligations" do
    field :description, :string
    field :completed, :boolean, default: false

    belongs_to :user, FollowThrough.User
    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @doc false
  def changeset(obligation, attrs \\ %{}) do
    obligation
    |> cast(attrs, [:description, :user_id, :team_id, :completed])
    |> validate_required([:description, :user_id, :team_id, :completed])
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

  def belongs_to_user?(obligation_id, user_id) do
    case Repo.get_by(__MODULE__, id: obligation_id, user_id: user_id) do
      %__MODULE__{} ->
        true
      nil ->
        false
    end
  end

  def mark_completed!(id) do
    Repo.get!(__MODULE__, id)
    |> changeset(%{completed: true})
    |> Repo.update!()
  end

  def mark_incomplete!(id) do
    Repo.get!(__MODULE__, id)
    |> changeset(%{completed: false})
    |> Repo.update!()
  end
end
