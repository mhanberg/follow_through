defmodule FollowThrough.Obligation do
  @moduledoc """
  This module describes the schema of the Obligation domain concept and stores
  functions for interacting with it.
  """
  use FollowThrough, :schema

  schema "obligations" do
    field :description, :string
    field :completed, :boolean, default: false

    belongs_to :user, FollowThrough.User
    belongs_to :team, FollowThrough.Team

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(obligation, attrs \\ %{}) do
    obligation
    |> cast(attrs, [:description, :user_id, :team_id, :completed])
    |> validate_required([:description, :user_id, :team_id, :completed])
  end

  def new do
    %__MODULE__{} |> changeset
  end

  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @spec get(integer() | String.t()) :: %__MODULE__{} | nil
  def get(id) do
    __MODULE__
    |> Repo.get(id)
  end

  @spec delete(%__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(%__MODULE__{} = obligation) do
    with {:ok, %__MODULE__{} = obligation} <- Repo.delete(obligation) do
      {:ok, obligation}
    else
      error ->
        error
    end
  end

  @spec for_user(integer()) :: [%__MODULE__{}]
  def for_user(user_id) do
    __MODULE__
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @spec for_team([%__MODULE__{}], integer()) :: [%__MODULE__{}]
  def for_team(obligations, team_id) do
    Enum.filter(obligations, &(&1.team_id == team_id))
  end

  @spec belongs_to_user?(obligation_id :: String.t(), user_id :: integer()) :: boolean()
  def belongs_to_user?(obligation_id, user_id) do
    case Repo.get_by(__MODULE__, id: obligation_id, user_id: user_id) do
      %__MODULE__{} ->
        true

      nil ->
        false
    end
  end

  @spec mark_completed!(String.t()) :: %__MODULE__{}
  def mark_completed!(id) do
    __MODULE__
    |> Repo.get!(id)
    |> changeset(%{completed: true})
    |> Repo.update!()
  end

  @spec mark_incomplete!(String.t()) :: %__MODULE__{}
  def mark_incomplete!(id) do
    __MODULE__
    |> Repo.get!(id)
    |> changeset(%{completed: false})
    |> Repo.update!()
  end
end
