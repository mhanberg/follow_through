defmodule FollowThroughWeb.PageController do
  use FollowThroughWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render("index.html")
  end

  def privacy(conn, _) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render("privacy.html")
  end
end
