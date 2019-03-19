defmodule FollowThroughWeb.SlackController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller
  alias FollowThrough.Subscription.Slash

  def slash(conn, %{"text" => text, "channel_id" => channel_id} = params) do
    assigns =
      text
      |> String.split(" ")
      |> Slash.parse(conn |> current_user(), params)

    conn
    |> put_status(200)
    |> render(assigns[:template], Keyword.merge(assigns, channel_id: channel_id))
  end
end
