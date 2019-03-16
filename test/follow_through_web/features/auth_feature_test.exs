defmodule FollowThroughWeb.AuthFeatureTest do
  use FollowThroughWeb.FeatureCase

  setup :login

  test "should be able to log in", %{session: session} do
    session
    |> assert_text("Logout")
  end
end
