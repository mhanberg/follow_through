defmodule FollowThrough.Subscription.Slash do
  @moduledoc """
  This module handles parsing slash commands from slack
  """
  alias FollowThrough.Subscription
  alias FollowThrough.Team
  alias FollowThrough.SlackToken
  import FollowThroughWeb.Helpers
  require Logger

  def parse(["help"], _conn, _params) do
    [template: :help]
  end

  def parse(["list"], conn, _params) do
    teams =
      conn
      |> current_user()
      |> FollowThrough.User.teams()

    [teams: teams, template: :list]
  end

  def parse(["subscribe" | rest], conn, %{"user_id" => user_id, "team_id" => team_id} = params) do
    requested_team = Enum.join(rest, " ")

    with %Team{} = team <- Team.get_by(name: requested_team) |> Team.with_users(),
         true <- Team.has_member?(team, current_user(conn)),
         %SlackToken{token: token} <- SlackToken.get_by_team(team_id),
         %{"ok" => true, "user" => %{"tz" => timezone}} <-
           Slack.Web.Users.info(user_id, %{include_locale: true, token: token}),
         {:ok, _} <- create_sub_and_start_digest(params, team, timezone) do
      [template: :subscription, team: team]
    else
      {:error, :create_sub, changeset, changes} ->
        [
          template: :error,
          error:
            changeset
            |> Ecto.Changeset.traverse_errors(&FollowThroughWeb.ErrorHelpers.translate_error/1)
            |> Map.fetch!(:team_id)
            |> List.first()
        ]

      error ->
        Logger.error(fn -> "Error subscribing #{inspect(error)}" end)

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
         delete_sub_and_terminate_digest(sub.id) do
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
    Ecto.Multi.new()
    |> Ecto.Multi.run(:create_sub, fn _, _ ->
      Subscription.create(%{
        channel_id: channel_id,
        channel_name: channel_name,
        service_team_id: slack_team_id,
        service: "Slack",
        team_id: team.id,
        timezone: timezone
      })
    end)
    |> Ecto.Multi.run(:start_digest, fn _, %{create_sub: sub} ->
      FollowThrough.DigestSupervisor.start_child(sub)
    end)
    |> FollowThrough.Repo.transaction()
  end

  defp delete_sub_and_terminate_digest(id) do
    FollowThrough.Repo.transaction(fn ->
      {:ok, %Subscription{}} = Subscription.delete(id)

      :ok = FollowThrough.DigestSupervisor.terminate_child(id)
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
