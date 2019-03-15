defmodule FollowThrough.SlackConnection do
  use Ecto.Schema
  import Ecto.Changeset
  alias FollowThrough.Repo

  schema "slack_connections" do
    field :slack_id, :string
    belongs_to :user, FollowThrough.User

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(slack_connection, attrs) do
    slack_connection
    |> cast(attrs, [:slack_id, :user_id])
    |> validate_required([:slack_id, :user_id])
    |> unique_constraint(:slack_id)
  end

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
