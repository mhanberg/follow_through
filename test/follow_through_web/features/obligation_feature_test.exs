defmodule FollowThroughWeb.ObligationFeatureTest do
  use FollowThroughWeb.FeatureCase

  setup :login

  setup %{current_user: current_user, session: session} do
    team = insert(:team, creator: current_user, users: [current_user])

    session =
      session
      |> visit("/teams")

    %{team: team, session: session}
  end

  test "can create a new obligation", %{session: session, team: team} do
    session
    |> click(css("[href=\"#{Routes.team_obligation_path(Endpoint, :new, team.id)}\"]"))
    |> fill_in(text_field("Description"), with: "This is a task I need to complete")
    |> click(button("Keep me on track"))
    |> assert_text("This is a task I need to complete")
  end

  test "can delete an obligation", %{session: session, team: team, current_user: current_user} do
    obligation = insert(:obligation, team: team, user: current_user)
    delete_path = Routes.team_obligation_path(Endpoint, :delete, team.id, obligation.id)

    message =
      session
      |> visit("/teams")
      |> click(css("[data-checkbox-id=\"#{obligation.id}\"]"))
      |> accept_confirm(&click(&1, css("[href=\"#{delete_path}\"]")))

    session |> assert_text("Successfully deleted an obligation")
    assert message == "Are you sure you want to delete this obligation?"
  end

  test "can complete an obligation", %{session: session, team: team, current_user: current_user} do
    obligation = insert(:obligation, team: team, user: current_user)
    obligation_selector = css("[data-checkbox-id=\"#{obligation.id}\"]")

    session =
      session
      |> visit("/teams")
      |> find(obligation_selector, fn p ->
        p
        |> click(css("svg"))
      end)

    Process.sleep(2000)

    session
    |> refute_has(obligation_selector)
  end
end
