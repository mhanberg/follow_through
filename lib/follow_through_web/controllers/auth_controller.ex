defmodule FollowThroughWeb.AuthController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller

  alias FollowThrough.{
    Credential,
    Email,
    Mailer,
    Repo,
    User
  }

  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  def new(conn, params) do
    conn
    |> render(:new, user: User.new(params), path: params["path"])
  end

  def create(conn, %{"user" => user, "path" => path}) do
    case %User{} |> User.changeset(user) |> FollowThrough.Repo.insert() do
      {:ok, %User{} = user} ->
        user
        |> Email.registration_email()
        |> Mailer.deliver_now()

        conn
        |> put_flash(:info, "Successfully registered!")
        |> put_session(:current_user, user)
        |> redirect(to: path)

      {:error, changeset} ->
        conn
        |> render(:new, user: changeset, path: path)
    end
  end

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

  if Application.get_env(:follow_through, :test) == true do
    # This is for use during testing
    def callback(conn, %{"provider" => "test", "id" => id}) do
      user = FollowThrough.Repo.get!(User, id)

      conn
      |> put_session(:current_user, user)
      |> redirect(to: Routes.team_path(conn, :index))
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"state" => path}) do
    Credential
    |> Repo.get_by(uid: to_string(auth.uid), provider: to_string(auth.provider))
    |> Kernel.is_nil()
    |> Kernel.&&(Regex.match?(~r/users\.noreply\.github\.com/, auth.info.email))
    |> case do
      true ->
        conn
        |> redirect(
          to:
            Routes.auth_path(conn, :new,
              uid: auth.uid,
              name: auth.info.name,
              image: auth.info.image,
              path: path
            )
        )

      _ ->
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
            |> put_flash(:error, "Failed to register. Please contact support.")
        end
        |> redirect(to: path)
    end
  end
end
