defmodule FollowThroughWeb.LayoutView do
  use FollowThroughWeb, :view

  defdelegate sign_in_button(conn), to: FollowThroughWeb.PageView
end
