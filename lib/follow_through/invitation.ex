defmodule FollowThrough.Invitation do
  use FollowThrough, :schema

  schema "invitations" do
    field :code, :string
    field :invited_email, :string

    belongs_to :sender, FollowThrough.User
    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs \\ %{}) do
    invitation
    |> cast(attrs, [:code, :invited_email, :team_id, :sender_id])
    |> validate_required([:code, :invited_email, :team_id, :sender_id])
  end

  def get(code, user) do
    Repo.get_by(__MODULE__, code: code, invited_email: user.email)
  end

  def new(attrs \\ %{}) do
    %__MODULE__{} |> changeset(attrs)
  end

  def with_team(%__MODULE__{} = invitation) do
    Repo.preload(invitation, :team)
  end

  def with_team(nil) do
    nil
  end

  def get_with_team(code, user) do
    code
    |> get(user)
    |> with_team()
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(Map.put(attrs, "code", generate_invite_code()))
    |> Repo.insert()
  end

  defp generate_invite_code do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> binary_part(0, 32)
  end
end
