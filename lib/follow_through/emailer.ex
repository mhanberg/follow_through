defmodule FollowThrough.Emailer do
  require Logger
  alias FollowThrough.Email
  alias FollowThrough.Invitation
  alias FollowThrough.Mailer
  alias FollowThrough.Repo
  alias FollowThrough.User
  defstruct [:send?, :invitation, :params, :error?]

  @type t() :: %__MODULE__{
          send?: nil | boolean(),
          invitation: nil | %Invitation{},
          params: nil | map(),
          error?: nil | boolean()
        }

  @spec new(map()) :: t()
  def new(params) do
    %__MODULE__{
      params: params
    }
  end

  @spec create_invite(t()) :: t()
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

  @spec send(t()) :: t()
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
