defmodule FollowThroughWeb.TeamController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Team

  def show(conn, %{"id" => id}) do
    render(conn, :show,
      team: Team.get!(id) |> FollowThrough.Repo.preload(:users)
    )
  end

  def new(conn, _params) do
    render(conn, :new, team: Team.new())
  end

  def create(conn, %{"team" => params}) do
    params = Map.put(params, "created_by_id", FollowThroughWeb.View.Helpers.current_user(conn).id)

    case Team.create(params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Successfully created team #{team.name}!")
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> render(:new, team: changeset)
    end
  end

  def join(conn, %{"invite_code" => invite_code}) do
    case Team.join(FollowThroughWeb.View.Helpers.current_user(conn), invite_code) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Successfully joined a team!")
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, %{"id" => id}) do
    case Team.delete(id) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Successfully deleted #{team.name}!")
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failed to delete #{changeset.data.name}")
        |> redirect(to: Routes.team_path(conn, changeset.data.id))
    end
  end
end
