defmodule FollowThrough.Invitation do
  use FollowThrough, :schema
  alias FollowThrough.Team
  alias FollowThrough.User

  schema "invitations" do
    field :code, :string
    field :invited_email, :string

    belongs_to :sender, User
    belongs_to :team, Team

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(invitation, attrs \\ %{}) do
    invitation
    |> cast(attrs, [:code, :invited_email, :team_id, :sender_id])
    |> validate_required([:code, :invited_email, :team_id, :sender_id])
  end

  @spec get(code :: String.t(), %User{}) :: %__MODULE__{}
  def get(code, user) do
    Repo.get_by(__MODULE__, code: code, invited_email: user.email)
  end

  @spec new(map()) :: Ecto.Changeset.t()
  def new(attrs \\ %{}) do
    %__MODULE__{} |> changeset(attrs)
  end

  @spec with_team(%__MODULE__{} | nil) :: %__MODULE__{} | nil
  def with_team(%__MODULE__{} = invitation) do
    Repo.preload(invitation, :team)
  end

  def with_team(nil) do
    nil
  end

  @spec get_with_team(String.t(), %User{}) :: %__MODULE__{}
  def get_with_team(code, user) do
    code
    |> get(user)
    |> with_team()
  end

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(Map.put(attrs, "code", generate_invite_code()))
    |> Repo.insert()
  end

  defp generate_invite_code do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> binary_part(0, 32)
  end
end
