defmodule FollowThrough.Team do
  use FollowThrough, :schema
  alias FollowThrough.Invitation
  alias FollowThrough.User

  schema "teams" do
    field :name, :string

    belongs_to :creator,
               FollowThrough.User,
               foreign_key: :created_by_id

    many_to_many :users,
                 FollowThrough.User,
                 join_through: FollowThrough.UsersTeams,
                 on_replace: :delete

    has_many :obligations, FollowThrough.Obligation

    timestamps()
  end

  @spec new() :: Ecto.Changeset.t()
  def new() do
    %__MODULE__{}
    |> changeset
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(team, attrs \\ %{}) do
    team
    |> cast(attrs, [:name, :created_by_id])
    |> validate_required([:name, :created_by_id])
  end

  @spec get(id :: integer() | String.t()) :: %__MODULE__{} | nil
  def get(id) do
    Repo.get(__MODULE__, id)
  end

  @spec get!(id :: integer() | String.t()) :: %__MODULE__{}
  def get!(id) do
    Repo.get!(__MODULE__, id)
  end

  @spec get_by(nonempty_list(tuple())) :: %__MODULE__{} | nil
  def get_by(attrs) do
    Repo.get_by(__MODULE__, attrs)
  end

  @spec with_users(%__MODULE__{} | nil) :: %__MODULE__{users: [%FollowThrough.User{}]} | nil
  def with_users(%__MODULE__{} = team) do
    Repo.preload(team, :users)
  end

  def with_users(team) when is_nil(team), do: nil

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
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

  @spec join(%User{}, String.t()) :: {:ok, %__MODULE__{}} | {:error, String.t()}
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

  @spec remove_member(id :: integer() | String.t(), member_id :: integer()) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
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

  @spec has_member?(%__MODULE__{users: [%User{}]}, %User{}) :: boolean()
  def has_member?(%__MODULE__{users: users}, user) do
    users
    |> Enum.any?(&(&1.id == user.id))
  end

  @spec is_admin?(%__MODULE__{}, %User{}) :: boolean()
  def is_admin?(team, user), do: team.created_by_id == user.id
end
