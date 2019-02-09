defmodule FollowThroughWeb.JoinTeamController do
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
        |> redirect(to: "/")
    end
  end

  def join(conn, %{"code" => code}) do
    case Team.join(current_user(conn), code) do
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
end
