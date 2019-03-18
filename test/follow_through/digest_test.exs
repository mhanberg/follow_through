defmodule FollowThrough.DigestTest do
  use FollowThrough.DataCase
  alias FollowThrough.Digest, as: D
  import Mox

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    start_supervised!({Registry, keys: :unique, name: ProcManager.Registry})

    :ok
  end

  test "fetches the subscription from the database on init" do
    expected = insert(:subscription)
    digest = start_supervised!({D, expected.id})

    assert %FollowThrough.Subscription{id: id} = :sys.get_state(digest)
    assert expected.id == id
  end

  test "fails to initialize if the subscription is not found" do
    assert :undefined == start_supervised!({D, 123})
  end

  test "sends the digest to slack" do
    obligation = insert(:obligation)
    subscription = insert(:subscription, team: obligation.team)
    insert(:slack_token, workspace_id: subscription.service_team_id)

    digest = start_supervised!({D, subscription.id})

    channel_id = subscription.channel_id

    FollowThrough.SlackClientMock
    |> expect(:post_message, fn ^channel_id, _, _ -> %{"ok" => true} end)

    Kernel.send(digest, :deliver)
    :sys.get_state(digest)
  end

  test "doesn't send the digest to slack if there are no incomplete obligations" do
    obligation = insert(:obligation, completed: true)
    subscription = insert(:subscription, team: obligation.team)
    insert(:slack_token, workspace_id: subscription.service_team_id)

    digest = start_supervised!({D, subscription.id})

    FollowThrough.SlackClientMock
    |> expect(:post_message, 0, fn _, _, _ -> nil end)

    Kernel.send(digest, :deliver)
    :sys.get_state(digest)
  end
end
