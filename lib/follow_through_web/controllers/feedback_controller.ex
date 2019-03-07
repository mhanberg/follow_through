defmodule FollowThroughWeb.FeedbackController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Feedback

  def create(conn, %{"feedback" => feedback}) do
    %Feedback{}
    |> Feedback.changeset(
      feedback
      |> Map.put("user_id", current_user(conn).id)
      |> Map.put("user_name", current_user(conn).name)
    )
    |> Feedback.create!()

    conn
    |> put_flash(:info, "Thank you for the feedback!")
    |> redirect(to: Routes.team_path(conn, :index))
  end
end
