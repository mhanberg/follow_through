defmodule FollowThroughWeb.PageController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render("index.html")
  end

  def login(conn, _) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render(:login)
  end

  def privacy(conn, _) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render("privacy.html")
  end
end
