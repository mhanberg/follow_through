defmodule FollowThroughWeb.PageController do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  use FollowThroughWeb, :controller

  plug :redirect_if_logged_in when action in [:index, :login]

  def index(conn, _params) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render("index.html")
  end

  def login(conn, params) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render(:login, path: params["path"] || "/")
  end

  def privacy(conn, _) do
    conn
    |> put_layout({FollowThroughWeb.LayoutView, "marketing.html"})
    |> render("privacy.html")
  end

  def redirect_if_logged_in(conn, _) do
    if logged_in?(conn) do
      conn
      |> redirect(to: Routes.team_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
