defmodule FollowThrough.Team do
  use FollowThrough, :schema
  alias FollowThrough.Invitation

  schema "teams" do
    field :name, :string

    belongs_to :creator,
               FollowThrough.User,
               foreign_key: :created_by_id

    many_to_many :users,
                 FollowThrough.User,
                 join_through: FollowThrough.UsersTeams,
                 on_replace: :delete

    timestamps()
  end

  def new() do
    %__MODULE__{}
    |> changeset
  end

  @doc false
  def changeset(team, attrs \\ %{}) do
    team
    |> cast(attrs, [:name, :created_by_id])
    |> validate_required([:name, :created_by_id])
  end

  def get(id) do
    Repo.get(__MODULE__, id)
  end

  def get!(id) do
    Repo.get!(__MODULE__, id)
  end

  def with_users(%__MODULE__{} = team) do
    Repo.preload(team, :users)
  end

  def create(attrs) do
    case %__MODULE__{}
         |> changeset(attrs)
         |> Repo.insert() do
      {:ok, team} ->
        creator =
          FollowThrough.User |> Repo.get(attrs["created_by_id"]) |> Ecto.Changeset.change()

        team
        |> Repo.preload(:users)
        |> changeset
        |> put_assoc(:users, [creator])
        |> Repo.update()

      {:error, error} ->
        {:error, error}
    end
  end

  def delete(id) do
    with team <- Repo.get(__MODULE__, id),
         {:ok, team} <- Repo.delete(team) do
      {:ok, team}
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def join(user, invite_code) do
    with %Invitation{} = invitation <- Invitation.get_with_team(invite_code, user),
         %__MODULE__{} = team <- with_users(invitation.team),
         false <- has_member?(team, user),
         {:ok, team} <- add_member(team, user) do
      {:ok, team}
    else
      nil ->
        {:error, "This invititation url has expired or is invalid."}

      true ->
        {:error, "You are already a member of this team!"}

      {:error, _changeset} ->
        {:error, "Something went wrong, please contact support"}
    end
  end

  defp add_member(team, user) do
    team
    |> Ecto.Changeset.change()
    |> put_assoc(:users, [user | team.users])
    |> Repo.update()
  end

  def remove_member(id, member_id) do
    with team <-
           __MODULE__
           |> Repo.get(id)
           |> Repo.preload(:users),
         {:ok, team} <-
           team
           |> Ecto.Changeset.change()
           |> put_assoc(:users, Enum.reject(team.users, &(&1.id == member_id)))
           |> Repo.update() do
      {:ok, team}
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def has_member?(%__MODULE__{users: users}, user) do
    users
    |> Enum.any?(&(&1.id == user.id))
  end

  def is_admin?(team, user), do: team.created_by_id == user.id
end
