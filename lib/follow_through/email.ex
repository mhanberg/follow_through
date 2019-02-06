defmodule FollowThrough.Email do
  use Bamboo.Phoenix, view: FollowThroughWeb.EmailView

  def registration_email(user) do
    new_email()
    |> to(user.email)
    |> from("support@followthrough.app")
    |> subject("Welcome to Follow Through!")
    |> render("registration.text", user: user)
  end
end
