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

IO.puts("Deleting all Users, Obligations...")
FollowThrough.Repo.delete_all(FollowThrough.User)
FollowThrough.Repo.delete_all(FollowThrough.Obligation)
Ecto.Adapters.SQL.query!(FollowThrough.Repo, "ALTER SEQUENCE users_id_seq RESTART WITH 1", [])

Ecto.Adapters.SQL.query!(
  FollowThrough.Repo,
  "ALTER SEQUENCE obligations_id_seq RESTART WITH 1",
  []
)

["alice", "bob", "carol", "dave"]
|> Enum.each(fn name ->
  user =
    FollowThrough.Repo.insert!(%FollowThrough.User{
      github_uid: :rand.uniform(1000),
      name: name,
      avatar: "123"
    })

  [
    "Schedule meeting with new client",
    "Organize get together for the managers",
    "Mentor the junior engineer",
    "Take my boss out to coffee"
  ]
  |> Enum.each(fn description ->
    FollowThrough.Repo.insert!(%FollowThrough.Obligation{
      description: description,
      user_id: user.id
    })
  end)
end)
