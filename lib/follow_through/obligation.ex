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

  @doc false
  def changeset(obligation, attrs \\ %{}) do
    obligation
    |> cast(attrs, [:description, :user_id, :team_id, :completed])
    |> validate_required([:description, :user_id, :team_id, :completed])
  end

  def new do
    %__MODULE__{} |> changeset
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get(id) do
    __MODULE__
    |> Repo.get(id)
  end

  def delete(%__MODULE__{} = obligation) do
    with {:ok, %__MODULE__{} = obligation} <- Repo.delete(obligation) do
      {:ok, obligation}
    else
      error ->
        error
    end
  end

  def delete(id) when is_binary(id) or is_integer(id) do
    with %__MODULE__{} = obligation <- get(id),
         {:ok, %__MODULE__{} = obligation} <- delete(obligation) do
      {:ok, obligation}
    else
      error ->
        error
    end
  end

  def for_user(user_id) do
    __MODULE__
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def for_team(obligations, team_id) do
    Enum.filter(obligations, &(&1.team_id == team_id))
  end

  def belongs_to_user?(obligation_id, user_id) do
    case Repo.get_by(__MODULE__, id: obligation_id, user_id: user_id) do
      %__MODULE__{} ->
        true

      nil ->
        false
    end
  end

  def mark_completed!(id) do
    __MODULE__
    |> Repo.get!(id)
    |> changeset(%{completed: true})
    |> Repo.update!()
  end

  def mark_incomplete!(id) do
    __MODULE__
    |> Repo.get!(id)
    |> changeset(%{completed: false})
    |> Repo.update!()
  end
end
