defmodule FollowThrough.User do
  use FollowThrough, :schema
  alias FollowThrough.Team
  require Ecto.Query

  schema "users" do
    field :github_uid, :integer
    field :slack_id, :string
    field :name, :string
    field :email, :string
    field :avatar, :string
    field :remember_me_token, :string

    has_many :obligations, FollowThrough.Obligation

    many_to_many :teams,
                 FollowThrough.Team,
                 join_through: FollowThrough.UsersTeams

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :avatar, :github_uid, :slack_id, :remember_me_token, :email])
    |> validate_required([:name, :avatar, :github_uid, :email])
    |> unique_constraint(:github_uid)
  end

  @spec new(map()) :: Ecto.Changeset.t()
  def new(auth) do
    %__MODULE__{}
    |> changeset(%{
      github_uid: auth["uid"],
      name: auth["name"],
      avatar: auth["image"]
    })
  end

  @spec update(%__MODULE__{}, map()) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def update(user, attrs) do
    user
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get(integer() | String.t()) :: %__MODULE__{} | nil
  def get(id), do: __MODULE__ |> Repo.get(id)

  @spec find_or_create(map()) ::
          {{:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}, :new | :existing}
  def find_or_create(auth) do
    case Repo.get_by(__MODULE__, github_uid: auth.uid) do
      %__MODULE__{} = user ->
        {{:ok, user}, :existing}

      nil ->
        %__MODULE__{}
        |> changeset(%{
          github_uid: auth.uid,
          name: auth.info.name,
          email: auth.info.email,
          avatar: auth.info.image
        })
        |> Repo.insert()
        |> wrap_as_new()
    end
  end

  @spec teams(%__MODULE__{}) :: [%Team{}]
  def teams(user) do
    user
    |> FollowThrough.Repo.preload(
      teams: [
        users: [
          obligations:
            Ecto.Query.from(o in FollowThrough.Obligation,
              where: o.completed == false,
              order_by: o.inserted_at
            )
        ]
      ]
    )
    |> Map.fetch!(:teams)
  end

  defp wrap_as_new(insert_result) do
    {insert_result, :new}
  end
end
