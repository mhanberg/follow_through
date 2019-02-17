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

  defp parse(["subscribe" | rest], conn, %{
         "channel_id" => channel_id,
         "team_id" => slack_team_id,
         "channel_name" => channel_name
       }) do
    requested_team = Enum.join(rest, " ")

    with %Team{} = team <- Team.get_by(name: requested_team) |> Team.with_users(),
         true <- Team.has_member?(team, current_user(conn)),
         {:ok, %Subscription{}} <-
           Subscription.create(%{
             channel_id: channel_id,
             channel_name: channel_name,
             service_team_id: slack_team_id,
             service: "Slack",
             team_id: team.id
           }) do
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
end
