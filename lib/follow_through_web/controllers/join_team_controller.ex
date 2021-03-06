defmodule FollowThroughWeb.JoinTeamController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller
  alias FollowThrough.Invitation
  alias FollowThrough.Team

  def new(conn, %{"code" => code}) do
    with %Invitation{} = invite <- Invitation.get_with_team(code, current_user(conn)) do
      render(conn, :new, invitation: invite)
    else
      nil ->
        conn
        |> put_flash(:error, "This invite link has expired or is invalid")
        |> redirect(to: Routes.team_path(conn, :index))
    end
  end

  def join(conn, %{"code" => code}) do
    conn
    |> current_user()
    |> Team.join(code)
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Successfully joined a team!")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
    end
    |> redirect(to: Routes.team_path(conn, :index))
  end
end
