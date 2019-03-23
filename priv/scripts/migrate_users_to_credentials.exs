FollowThrough.Repo.transaction(fn ->
  FollowThrough.User
  |> FollowThrough.Repo.all()
  |> Enum.each(fn user ->
    FollowThrough.Repo.insert(
      %FollowThrough.Credential{
        uid: to_string(user.github_uid),
        provider: "github",
        user_id: user.id
      }
    )
  end)
end)
