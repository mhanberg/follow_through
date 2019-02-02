defmodule FollowThroughWeb.PageController do
  use FollowThroughWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
