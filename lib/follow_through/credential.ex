defmodule FollowThrough.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :uid, :string
    field :provider, :string

    belongs_to :user, FollowThrough.User

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:uid, :provider])
    |> validate_required([:uid, :provider])
    |> unique_constraint(:uid, name: :credentials_uid_provider_index)
  end
end
