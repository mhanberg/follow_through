defmodule FollowThroughWeb.FeedbackController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller
  alias FollowThrough.Feedback

  plug :put_layout, false

  def new(conn, _) do
    conn
    |> render(:new, feedback: Feedback.changeset(%Feedback{}), message: message())
  end

  def create(conn, %{"feedback" => feedback}) do
    %Feedback{}
    |> Feedback.changeset(
      feedback
      |> Map.put("user_id", current_user(conn).id)
      |> Map.put("user_name", current_user(conn).name)
    )
    |> Feedback.create()
    |> handle_create(conn)
  end

  defp handle_create(:ok, conn) do
    conn
    |> render(:form,
      feedback: Feedback.changeset(%Feedback{}),
      message: message("Thanks for the feedback!", "green-500")
    )
  end

  defp handle_create({:github_error, feedback}, conn) do
    conn
    |> render(:form, feedback: feedback, message: message("Something went wrong", "red"))
  end

  defp handle_create({:error, feedback}, conn) do
    conn
    |> render(:form, feedback: feedback, message: message())
  end

  defp message(), do: %{message: nil, status: nil}

  defp message(message, status) do
    %{message: message, status: status}
  end
end
