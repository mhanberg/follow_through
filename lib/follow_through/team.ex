defmodule FollowThrough.Team do
  use FollowThrough, :schema

  schema "teams" do
    field :name, :string
    field :invite_code, :string

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
    |> cast(attrs, [:name, :created_by_id, :invite_code])
    |> validate_required([:name, :created_by_id, :invite_code])
  end

  def get!(id) do
    Repo.get!(__MODULE__, id)
  end

  def create(attrs) do
    attrs = Map.put(attrs, "invite_code", generate_invite_code())

    case %__MODULE__{}
         |> changeset(attrs)
         |> Repo.insert() do
      {:ok, team} ->
        creator = Repo.get(FollowThrough.User, attrs["created_by_id"]) |> Ecto.Changeset.change()

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
    case Repo.get_by(Ecto.Query.preload(__MODULE__, :users), invite_code: invite_code) do
      nil ->
        {:error, "This invititation url has expired or is invalid."}

      team ->
        unless has_member?(team, user) do
          case team
               |> Ecto.Changeset.change()
               |> put_assoc(:users, [user | team.users])
               |> Repo.update() do
            {:ok, team} ->
              {:ok, team}

            {:error, _changeset} ->
              {:error, "Something went wrong, please contact support"}
          end
        else
          {:error, "You are already a member of this team!"}
        end
    end
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

  def generate_invite_code do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> binary_part(0, 32)
  end
end
