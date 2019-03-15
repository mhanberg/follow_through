defmodule FollowThrough.FeedbackTest do
  use ExUnit.Case, async: true
  alias FollowThrough.Feedback

  import Mox

  setup :verify_on_exit!

  test "returns :ok after successfull post to github" do
    FollowThrough.HttpMock
    |> expect(:post, fn _, _, _ -> {:ok, %HTTPoison.Response{status_code: 201}} end)

    actual =
      %Feedback{}
      |> Feedback.changeset(%{
        title: "Title",
        message: "Message",
        user_id: 1,
        user_name: "Name"
      })
      |> Feedback.create()

    assert :ok == actual
  end

  test "returns {:error, Ecto.Changeset.t()} when there is a validation error" do
    actual =
      %Feedback{}
      |> Feedback.changeset(%{})
      |> Feedback.create()

    assert {:error, %Ecto.Changeset{}} = actual
  end

  test "returns {:github_error, Ecto.Changeset.t()} when there is an error posting to github" do
    FollowThrough.HttpMock
    |> expect(:post, fn _, _, _ -> {:ok, %HTTPoison.Response{status_code: 400}} end)

    actual =
      %Feedback{}
      |> Feedback.changeset(%{
        title: "Title",
        message: "Message",
        user_id: 1,
        user_name: "Name"
      })
      |> Feedback.create()

    assert {:github_error, %Ecto.Changeset{}} = actual
  end
end
