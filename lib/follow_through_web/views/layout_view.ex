defmodule FollowThroughWeb.LayoutView do
  use FollowThroughWeb, :view

  defdelegate sign_in_button(conn, provider, button_classes), to: FollowThroughWeb.PageView
end
