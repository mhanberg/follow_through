defmodule FollowThrough.SlackToken do
  use FollowThrough, :schema

  schema "slack_tokens" do
    field :token, :string
    field :workspace_id, :string

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
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

  @spec get_by_team(String.t()) :: %__MODULE__{}
  def get_by_team(workspace_id) do
    Repo.get_by(__MODULE__, workspace_id: workspace_id)
  end
end
