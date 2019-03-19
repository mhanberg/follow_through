defmodule FollowThrough.SlashTest do
  use FollowThrough.DataCase
  import Mox

  alias FollowThrough.Subscription
  alias FollowThrough.Subscription.Slash

  setup :verify_on_exit!

  setup do
    start_supervised!(FollowThrough.DigestSupervisor)
    :ok
  end

  test "can subscribe to a team" do
    team = insert(:team)
    expected_workspace_id = "workspaceid"

    %FollowThrough.SlackToken{token: token} =
      insert(:slack_token, workspace_id: expected_workspace_id)

    user = team.users |> List.first()
    user_id = user.id
    command = ["subscribe", team.name]
    expected_timezone = "America/Indiana/Indianapolis"

    FollowThrough.SlackClientMock
    |> expect(:info, fn ^user_id, %{include_locale: true, token: ^token} ->
      %{"ok" => true, "user" => %{"tz" => expected_timezone}}
    end)

    expected = [template: :subscription, team: team]

    actual =
      Slash.parse(command, user, %{
        "channel_id" => "123abc",
        "user_id" => user.id,
        "team_id" => expected_workspace_id,
        "channel_name" => "Channel Name!"
      })

    assert expected[:template] == actual[:template]
    assert expected[:team].id == actual[:team].id

    assert Repo.exists?(
             Subscription
             |> from()
             |> where(channel_id: "123abc")
             |> where(channel_name: "Channel Name!")
             |> where(service_team_id: ^expected_workspace_id)
             |> where(service: "Slack")
             |> where(team_id: ^team.id)
             |> where(timezone: ^expected_timezone)
           )
  end
end
