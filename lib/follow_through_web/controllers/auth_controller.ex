defmodule FollowThroughWeb.AuthController do
  use FollowThroughWeb, :controller
  alias FollowThrough.{User, Mailer, Email}

  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  def delete(conn, _) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out!")
    |> redirect(to: "/")
  end

  def slack(conn, %{"code" => code}) do
    with {:ok, _resp} <- auth_with_slack(code) do
      conn
      |> put_flash(:info, "Successfully added to slack!")
      |> redirect(to: "/")
    else
      {:error, _error} ->
        conn
        |> put_flash(:error, "Failed to authenticate with Slack")
        |> redirect(to: "/")
    end
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

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    auth
    |> User.find_or_create()
    |> case do
      {{:ok, user}, :new} ->
        user
        |> Email.registration_email()
        |> Mailer.deliver_now()

        conn
        |> put_flash(:info, "Successfully registered!")
        |> put_session(:current_user, user)

      {{:ok, user}, :existing} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)

      {{:error, _changeset}, :new} ->
        conn
        |> put_flash(:error, "Failed to register. Pleaes contact support.")
    end
    |> redirect(to: "/")
  end
end
