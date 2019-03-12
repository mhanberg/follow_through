defmodule FollowThroughWeb.AuthFeatureTest do
  use FollowThroughWeb.FeatureCase
  alias FollowThrough.User

  setup %{session: session} do
    {:ok, user} =
      Repo.insert(%User{
        github_uid: 1,
        avatar: "yep",
        email: "test@example.com",
        name: "test user"
      })

    session =
      session
      |> visit("/auth/test/callback?id=#{user.id}")

    %{session: session}
  end

  test "should be able to log in", %{session: session} do
    session
    |> assert_text("Logout")
  end
end
