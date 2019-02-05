defmodule FollowThroughWeb.TeamMemberController do
  use FollowThroughWeb, :controller

  def delete(conn, %{"team_id" => team_id, "id" => id}) do
    case FollowThrough.Team.remove_member(String.to_integer(team_id), String.to_integer(id)) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Successfully removed team member!")
        |> redirect(to: Routes.team_path(conn, :show, team_id))
      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to remove member.")
        |> redirect(to: Routes.team_path(conn, :show, team_id))
    end
  end
end
