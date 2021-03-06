defmodule FollowThroughWeb.SlackAuthController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller
  alias FollowThrough.SlackToken

  def new(conn, %{"user_id" => user_id}) do
    conn
    |> render(:new, user_id: user_id)
  end

  def create(conn, %{"slack_connect" => params}) do
    with {:ok, _slack_connection} <-
           FollowThrough.SlackConnection.create(Map.put(params, "user_id", current_user(conn).id)) do
      conn
      |> put_flash(:info, "Successfully connected your Slack account")
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong, please contact support")
    end
    |> redirect(to: Routes.team_path(conn, :index))
  end

  def callback(conn, %{"code" => code}) do
    with {:ok, resp} <- auth_with_slack(code),
         {:ok, %SlackToken{}} <- SlackToken.create(decode_resp(resp)) do
      conn
      |> put_flash(:info, "Successfully added to slack!")
    else
      {:error, _error} ->
        conn
        |> put_flash(:error, "Failed to authenticate with Slack")
    end
    |> redirect(to: Routes.team_path(conn, :index))
  end

  def callback(conn, %{"error" => "access_denied"}) do
    conn
    |> redirect(to: Routes.team_path(conn, :index))
  end

  def install(conn, _) do
    conn
    |> put_status(302)
    |> redirect(
      external:
        "https://slack.com/oauth/authorize?client_id=#{System.get_env("SLACK_CLIENT_ID")}&scope=commands,users:read,chat:write:bot"
    )
  end

  defp decode_resp(%HTTPoison.Response{body: body}) do
    %{"access_token" => access_token, "team_id" => team_id} =
      body
      |> Jason.decode!()

    %{token: access_token, workspace_id: team_id}
  end

  defp auth_with_slack(code) do
    HTTPoison.post(
      "https://slack.com/api/oauth.access",
      {:form,
       [
         client_id: System.get_env("SLACK_CLIENT_ID"),
         client_secret: System.get_env("SLACK_CLIENT_SECRET"),
         code: code
       ]},
      [{"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}]
    )
  end
end
