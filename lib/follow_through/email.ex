defmodule FollowThrough.Email do
  use Bamboo.Phoenix, view: FollowThroughWeb.EmailView

  def registration_email(user) do
    basic_email()
    |> to(user.email)
    |> subject("Welcome to Follow Through!")
    |> render("registration.text", user: user)
  end

  def invitation_email(invitation) do
    basic_email()
    |> to(invitation.invited_email)
    |> subject("You've been invited to join #{invitation.team.name}")
    |> render("invitation.html", invitation: invitation)
  end

  defp basic_email() do
    new_email()
    |> from("support@followthrough.app")
  end
end
