defmodule FollowThroughWeb.LayoutView do
  use FollowThroughWeb, :view

  defdelegate sign_in_button(conn, provider, opts), to: FollowThroughWeb.PageView
end
