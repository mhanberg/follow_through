defmodule FollowThroughWeb.Helpers do
  alias FollowThrough.User

  @spec current_user(%Plug.Conn{}) :: %User{} | nil
  def current_user(conn) do
    Plug.Conn.get_session(conn, :current_user)
  end

  @spec logged_in?(%Plug.Conn{}) :: boolean()
  def logged_in?(conn), do: current_user(conn) != nil
end
