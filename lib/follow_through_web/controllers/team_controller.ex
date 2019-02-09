defmodule FollowThroughWeb.TeamController do
  use FollowThroughWeb, :controller
  alias FollowThrough.{Team, Invitation}

  def show(conn, %{"id" => id}) do
    team =
      Team.get!(id)
      |> Team.with_users()

    render(conn, :show,
      team: team,
      invitation: Invitation.new()
    )
  end

  def new(conn, _params) do
    render(conn, :new, team: Team.new())
  end

  def create(conn, %{"team" => params}) do
    params = Map.put(params, "created_by_id", current_user(conn).id)

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
