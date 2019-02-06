# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FollowThrough.Repo.insert!(%FollowThrough.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FollowThrough.{User, Obligation, Team, UsersTeams, Repo}

IO.puts("Deleting all Users, Obligations, Teams...")
Repo.delete_all(User)
Repo.delete_all(Obligation)
Repo.delete_all(Team)
Ecto.Adapters.SQL.query!(Repo, "ALTER SEQUENCE users_id_seq RESTART WITH 1", [])
Ecto.Adapters.SQL.query!(Repo, "ALTER SEQUENCE obligations_id_seq RESTART WITH 1", [])
Ecto.Adapters.SQL.query!(Repo, "ALTER SEQUENCE teams_id_seq RESTART WITH 1", [])

["alice", "bob", "carol", "dave"]
|> Enum.each(fn name ->
  user =
    Repo.insert!(%User{
      github_uid: :rand.uniform(1000),
      name: name,
      email: "#{name}@example.com",
      avatar: "123"
    })
end)

Repo.insert!(%Team{name: "Team 1", created_by_id: 1, invite_code: Team.generate_invite_code()})
Repo.insert!(%UsersTeams{user_id: 1, team_id: 1})
Repo.insert!(%UsersTeams{user_id: 2, team_id: 1})

Repo.insert!(%Team{name: "Team A", created_by_id: 3, invite_code: Team.generate_invite_code()})
Repo.insert!(%UsersTeams{user_id: 3, team_id: 2})
Repo.insert!(%UsersTeams{user_id: 4, team_id: 2})

for description <- [
      "Schedule meeting with new client",
      "Organize get together for the managers",
      "Mentor the junior engineer",
      "Take my boss out to coffee"
    ],
    user <- Repo.all(User),
    team <- Repo.all(Team) do
  Repo.insert!(%Obligation{
    description: description,
    user_id: user.id,
    team_id: team.id
  })
end
