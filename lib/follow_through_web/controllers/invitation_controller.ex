defmodule FollowThroughWeb.InvitationController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller
  alias FollowThrough.Emailer

  def create(conn, %{"invitation" => params}) do
    params
    |> Emailer.new()
    |> Emailer.create_invite()
    |> Emailer.send()
    |> case do
      %Emailer{error?: true} ->
        conn
        |> put_flash(:error, "Something went wrong, please contact support")

      _ ->
        conn
        |> put_flash(:info, "Successfully invited #{params["invited_email"]}")
    end
    |> redirect(to: Routes.team_path(conn, :show, params["team_id"]))
  end
end
