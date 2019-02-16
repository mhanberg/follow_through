defmodule FollowThroughWeb.SlackController do
  use FollowThroughWeb, :controller

  def slash(conn, %{"text" => text, "channel_id" => channel_id}) do
    assigns =
      text
      |> String.split(" ")
      |> parse(conn)

    conn
    |> put_status(200)
    |> render(assigns[:template], Keyword.merge(assigns, channel_id: channel_id))
  end

  defp parse(["list"], conn) do
    teams =
      conn
      |> current_user()
      |> FollowThrough.User.teams()

    [teams: teams, template: :list]
  end

  defp parse(_, _) do
    [template: :error]
  end
end
