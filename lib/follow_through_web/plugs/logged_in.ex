defmodule FollowThroughWeb.LoggedIn do
  @behaviour Plug
  import Plug.Conn
  import FollowThroughWeb.Helpers
  alias FollowThroughWeb.Router.Helpers, as: Routes

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    case current_user(conn) do
      nil ->
        conn
        |> Phoenix.Controller.redirect(
          to: Routes.page_path(conn, :login, path: conn.request_path)
        )
        |> halt()

      _ ->
        conn
    end
  end
end
