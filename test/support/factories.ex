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
    user = build(:user)

    %FollowThrough.Team{
      name: sequence(:name, &"Team#{&1}"),
      creator: user,
      users: [user]
    }
  end

  def obligation_factory do
    user = build(:user)

    %FollowThrough.Obligation{
      description: sequence(:description, &"Obligation #{&1}"),
      completed: false,
      user: user,
      team: build(:team, creator: user, users: [user])
    }
  end
end
