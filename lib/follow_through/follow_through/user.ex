defmodule FollowThrough.User do
  use FollowThrough, :schema

  schema "users" do
    field :avatar, :string
    field :github_uid, :integer
    field :name, :string
    field :remember_me_token, :string

    has_many :obligations, FollowThrough.Obligation
    many_to_many :teams, FollowThrough.Team, join_through: FollowThrough.UsersTeams

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :avatar, :github_uid, :remember_me_token])
    |> validate_required([:name, :avatar, :github_uid])
    |> unique_constraint(:github_uid)
  end

  def find_or_create(auth) do
    case Repo.get_by(__MODULE__, github_uid: auth.uid) do
      %__MODULE__{} = user ->
        {:ok, user}

      nil ->
        %__MODULE__{}
        |> changeset(%{
          github_uid: auth.uid,
          name: auth.info.name,
          avatar: auth.info.image
        })
        |> Repo.insert()
    end
  end
end
