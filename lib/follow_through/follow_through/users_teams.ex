defmodule FollowThrough.UsersTeams do
  use FollowThrough, :schema

  @primary_key false
  schema "users_teams" do
    belongs_to :user, FollowThrough.User
    belongs_to :team, FollowThrough.Team

    timestamps()
  end
end
