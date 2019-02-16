defmodule FollowThroughWeb.PageController do
  use FollowThroughWeb, :controller
  alias FollowThrough.User

  def index(conn, _params) do
    teams =
      conn
      |> current_user
      |> User.teams()

    render(conn, "index.html", teams: teams)
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end
end
