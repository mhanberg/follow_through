defmodule FollowThroughWeb.SlackController do
  use FollowThroughWeb, :controller
  alias FollowThrough.{Subscription, Team}

  def slash(conn, %{"text" => text, "channel_id" => channel_id} = params) do
    assigns =
      text
      |> String.split(" ")
      |> parse(conn, params)

    conn
    |> put_status(200)
    |> render(assigns[:template], Keyword.merge(assigns, channel_id: channel_id))
  end

  defp parse(["list"], conn, _params) do
    teams =
      conn
      |> current_user()
      |> FollowThrough.User.teams()

    [teams: teams, template: :list]
  end

  defp parse(["subscribe" | rest], conn, params) do
    requested_team = Enum.join(rest, " ")

    with %Team{} = team <- Team.get_by(name: requested_team) |> Team.with_users(),
         true <- Team.has_member?(team, current_user(conn)),
         create_sub_and_start_digest(params, team) do
      [template: :subscription, team: team]
    else
      {:error, %Ecto.Changeset{errors: [{_, message}]}} ->
        [template: :error, error: translate_error(message)]

      _ ->
        error_message =
          if requested_team != "" do
            "Could not subscribe to team #{requested_team}"
          else
            "A team name is required when using the subscribe command"
          end

        [template: :error, error: error_message]
    end
  end

  defp parse(_, _, _) do
    [template: :error]
  end

  defp create_sub_and_start_digest(
         %{
           "channel_id" => channel_id,
           "team_id" => slack_team_id,
           "channel_name" => channel_name
         },
         team
       ) do
    FollowThrough.Repo.transaction(fn ->
      {:ok, %Subscription{} = sub} =
        Subscription.create(%{
          channel_id: channel_id,
          channel_name: channel_name,
          service_team_id: slack_team_id,
          service: "Slack",
          team_id: team.id
        })

      FollowThrough.DigestSupervisor.start_child(sub)
    end)
  end
end
