defmodule FollowThroughWeb.TeamFeatureTest do
  use FollowThroughWeb.FeatureCase

  setup :login

  setup %{session: session} do
    session =
      session
      |> visit("/teams")

    %{session: session}
  end

  test "shows the empty state when a user doesn't belong to a team", %{session: session} do
    session
    |> assert_text("Create a new team")

    session
    |> assert_has(link("Create team"))
  end

  test "creates a new team", %{session: session} do
    session
    |> click(link("Create team"))
    |> fill_in(text_field("Name"), with: "Seal Team Ricks")
    |> click(button("create"))
    |> assert_text("Successfully created team Seal Team Ricks")
  end

  test "requires a name to create a new team", %{session: session} do
    session
    |> visit("/teams/new")
    |> click(button("create"))
    |> assert_text("can't be blank")
  end

  test "team name links to the team page", %{session: session, current_user: current_user} do
    team = insert(:team, creator: current_user, users: [current_user])

    session =
      session
      |> visit("/teams")
      |> click(link(team.name))

    session |> assert_text(team.name)
    session |> assert_text(current_user.name)

    assert Routes.team_path(FollowThroughWeb.Endpoint, :show, team.id) ==
             session |> current_path()
  end

  test "can delete a team", %{session: session, current_user: current_user} do
    team = insert(:team, creator: current_user, users: [current_user])

    message =
      session
      |> visit(Routes.team_path(FollowThroughWeb.Endpoint, :show, team.id))
      |> accept_confirm(&click(&1, link("Delete Team")))

    session |> assert_text("Successfully deleted #{team.name}!")
    assert message == "Are you sure you want to delete the team #{team.name}?"
  end
end
