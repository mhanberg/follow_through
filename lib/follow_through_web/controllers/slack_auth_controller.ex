defmodule FollowThroughWeb.SlackAuthController do
  use FollowThroughWeb, :controller

  def new(conn, %{"user_id" => user_id}) do
    conn
    |> render(:new, user_id: user_id)
  end

  def create(conn, %{"slack_connect" => params}) do
    with {:ok, _user} <- FollowThrough.User.update(current_user(conn), params) do
      conn
      |> put_flash(:info, "Successfully connected your Slack account")
      |> redirect(to: "/")
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong, please contact support")
        |> redirect(to: "/")
    end
  end

  def callback(conn, %{"code" => code}) do
    with {:ok, _resp} <- auth_with_slack(code) do
      conn
      |> put_flash(:info, "Successfully added to slack!")
    else
      {:error, _error} ->
        conn
        |> put_flash(:error, "Failed to authenticate with Slack")
    end
    |> redirect(to: "/")
  end

  def callback(conn, %{"error" => "access_denied"}) do
    conn
    |> redirect(to: "/")
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
