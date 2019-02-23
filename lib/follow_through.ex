defmodule FollowThrough do
  @moduledoc """
  FollowThrough keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query
      alias FollowThrough.Repo

      @spec all() :: [%__MODULE__{}]
      def all() do
        Repo.all(__MODULE__)
      end

      @spec delete(String.t() | integer()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
      def delete(id) when is_integer(id) or is_binary(id) do
        with resource <- Repo.get(__MODULE__, id),
             {:ok, resource} <- Repo.delete(resource) do
          {:ok, resource}
        else
          {:error, changeset} ->
            {:error, changeset}
        end
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
