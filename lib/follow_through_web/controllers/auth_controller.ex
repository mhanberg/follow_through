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

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case User.find_or_create(auth) do
      {{:ok, user}, :new} ->
        user
        |> Email.registration_email()
        |> Mailer.deliver_now()

        conn
        |> put_flash(:info, "Successfully registered!")
        |> put_session(:current_user, user)
        |> redirect(to: "/")

      {{:ok, user}, :existing} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")

      {{:error, _changeset}, :new} ->
        conn
        |> put_flash(:error, "Failed to register. Pleaes contact support.")
        |> redirect(to: "/")
    end
  end
end
