defmodule FollowThrough.Subscription.Slash do
  @moduledoc """
  This module handles parsing slash commands from slack
  """
  alias FollowThrough.{Subscription, Team}
  import FollowThroughWeb.Helpers

  def parse(["list"], conn, _params) do
    teams =
      conn
      |> current_user()
      |> FollowThrough.User.teams()

    [teams: teams, template: :list]
  end

  def parse(["subscribe" | rest], conn, %{"user_id" => user_id} = params) do
    requested_team = Enum.join(rest, " ")

    with %Team{} = team <- Team.get_by(name: requested_team) |> Team.with_users(),
         true <- Team.has_member?(team, current_user(conn)),
         %{"ok" => true, "user" => %{"tz" => timezone}} <-
           Slack.Web.Users.info(user_id, %{include_locale: true}),
         create_sub_and_start_digest(params, team, timezone) do
      [template: :subscription, team: team]
    else
      {:error, %Ecto.Changeset{errors: [{_, message}]}} ->
        [template: :error, error: FollowThroughWeb.ErrorHelpers.translate_error(message)]

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

  def parse(
        ["unsubscribe" | rest],
        conn,
        %{
          "channel_id" => channel_id,
          "team_id" => slack_team_id
        }
      ) do
    requested_team = Enum.join(rest, " ")

    with %Team{} = team <- authorized?(conn, requested_team),
         %Subscription{} = sub <-
           Subscription.get_by(
             channel_id: channel_id,
             service_team_id: slack_team_id,
             team_id: team.id,
             service: "Slack"
           ),
         {:ok, %Subscription{}} <- Subscription.delete(sub.id) do
      [template: :unsubscribe, team: team]
    else
      _ ->
        [template: :error, error: "Unable to complete that action"]
    end
  end

  def parse(_, _, _) do
    [template: :error]
  end

  defp create_sub_and_start_digest(
         %{
           "channel_id" => channel_id,
           "team_id" => slack_team_id,
           "channel_name" => channel_name
         },
         team,
         timezone
       ) do
    FollowThrough.Repo.transaction(fn ->
      {:ok, %Subscription{} = sub} =
        Subscription.create(%{
          channel_id: channel_id,
          channel_name: channel_name,
          service_team_id: slack_team_id,
          service: "Slack",
          team_id: team.id,
          delivery_time: Subscription.delivery_time_in_utc(timezone)
        })

      {:ok, _} = FollowThrough.DigestSupervisor.start_child(sub)
    end)
  end

  defp authorized?(conn, requested_team) do
    with %Team{} = team <- Team.get_by(name: requested_team) |> Team.with_users(),
         true <- Team.has_member?(team, current_user(conn)) do
      team
    else
      _ ->
        false
    end
  end
end
