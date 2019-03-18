defmodule FollowThrough.Factory do
  use ExMachina.Ecto, repo: FollowThrough.Repo

  def user_factory do
    %FollowThrough.User{
      github_uid: sequence(:github_uid, & &1),
      avatar: sequence(:avatar, &"github-avatar-url.example.com/#{&1}"),
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence(:name, &"user#{&1}")
    }
  end

  def team_factory do
    user = insert(:user)

    %FollowThrough.Team{
      name: sequence(:name, &"Team#{&1}"),
      creator: user,
      users: [user]
    }
  end

  def obligation_factory do
    user = insert(:user)

    %FollowThrough.Obligation{
      description: sequence(:description, &"Obligation #{&1}"),
      completed: false,
      user: user,
      team: build(:team, creator: user, users: [user])
    }
  end

  def subscription_factory do
    %FollowThrough.Subscription{
      channel_id: sequence(:channel_id, &"#{&1}"),
      channel_name: sequence(:channel_name, &"Channel #{&1}"),
      service_team_id: sequence(:service_team_id, &"Service team #{&1}"),
      service: "Slack",
      timezone: "America/Indiana/Indianapolis",
      team: build(:team)
    }
  end

  def slack_token_factory do
    %FollowThrough.SlackToken{
      token: "tokenstring",
      workspace_id: sequence(:workspace_id, &"workspace_id_#{&1}")
    }
  end
end
