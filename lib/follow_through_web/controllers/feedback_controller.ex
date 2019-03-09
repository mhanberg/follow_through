defmodule FollowThroughWeb.FeedbackController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Feedback

  plug :put_layout, false

  def new(conn, _) do
    conn
    |> render(:new, feedback: Feedback.changeset(%Feedback{}), message: message)
  end

  def create(conn, %{"feedback" => feedback}) do
    %Feedback{}
    |> Feedback.changeset(
      feedback
      |> Map.put("user_id", current_user(conn).id)
      |> Map.put("user_name", current_user(conn).name)
    )
    |> Feedback.create()
    |> case do
      :ok ->
        conn
        |> render(:form,
          feedback: Feedback.changeset(%Feedback{}),
          message: message("Thanks for the feedback!", "green-500")
        )

      {:github_error, feedback} ->
        conn
        |> render(:form, feedback: feedback, message: message("Something went wrong", "red"))

      {:error, feedback} ->
        conn
        |> render(:form, feedback: feedback, message: message)
    end
  end

  def message(), do: %{message: nil, status: nil}

  def message(message, status) do
    %{message: message, status: status}
  end
end
