defmodule FollowThroughWeb.InvitationController do
  use FollowThroughWeb, :controller
  alias FollowThrough.{Team, Invitation, Mailer, Email}

  def create(conn, %{"invitation" => params}) do
    with {:ok, invitation} <-
           params
           |> Invitation.create(),
         invitation
         |> Invitation.with_team()
         |> Email.invitation_email()
         |> Mailer.deliver_now() do
      conn
      |> put_flash(:info, "Successfully invited #{params["invited_email"]}")
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong, please contact support")
    end
    |> redirect(to: Routes.team_path(conn, :show, params["team_id"]))
  end
end
