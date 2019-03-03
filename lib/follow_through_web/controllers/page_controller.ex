defmodule FollowThroughWeb.PageController do
  use FollowThroughWeb, :controller

  plug :put_layout, :marketing

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
