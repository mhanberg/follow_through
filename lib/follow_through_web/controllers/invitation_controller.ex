defmodule FollowThroughWeb.InvitationController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Invitation

  defmodule Emailer do
    require Logger
    alias FollowThrough.Mailer
    alias FollowThrough.Email
    alias FollowThrough.User
    alias FollowThrough.Invitation
    alias FollowThrough.Repo
    defstruct [:send?, :invitation, :params, :error?]

    def new(params) do
      %__MODULE__{
        params: params
      }
    end

    def create_invite(%__MODULE__{params: params} = emailer) do
      case Repo.get_by(User, email: params["invited_email"]) do
        %User{} ->
          case Invitation.create(params) do
            {:ok, invite} ->
              invite = invite |> Invitation.with_team()

              struct(emailer, send?: true, invitation: invite)

            {:error, _changeset} ->
              struct(emailer, send?: false, error?: true)
          end

        nil ->
          struct(emailer, send?: false)
      end
    end

    def send(%__MODULE__{invitation: invitation, send?: send?} = emailer) do
      if send? do
        Logger.debug(fn -> "Sending invitation email to #{inspect(invitation.invited_email)}" end)

        invitation
        |> Email.invitation_email()
        |> Mailer.deliver_now()
      else
        Logger.debug(fn -> "Not sending invitation email." end)
      end

      emailer
    end
  end

  def create(conn, %{"invitation" => params}) do
    params
    |> Emailer.new()
    |> Emailer.create_invite()
    |> Emailer.send()
    |> case do
      %Emailer{error?: true} ->
        conn
        |> put_flash(:error, "Something went wrong, please contact support")

      _ ->
        conn
        |> put_flash(:info, "Successfully invited #{params["invited_email"]}")
    end
    |> redirect(to: Routes.team_path(conn, :show, params["team_id"]))
  end
end
