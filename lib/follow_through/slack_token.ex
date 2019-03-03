defmodule FollowThrough.SlackToken do
  use FollowThrough, :schema

  schema "slack_tokens" do
    field :token, :string
    field :workspace_id, :string

    timestamps()
  end

  @doc false
  def changeset(slack_token, attrs) do
    slack_token
    |> cast(attrs, [:token, :workspace_id])
    |> validate_required([:token, :workspace_id])
    |> unique_constraint(:token)
    |> unique_constraint(:workspace_id)
  end

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_by_team(team) do
    Repo.get_by(__MODULE__, workspace_id: team)
  end
end
