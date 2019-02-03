defmodule FollowThroughWeb.PageView do
  use FollowThroughWeb, :view

  def obligations(conn) do
    conn
    |> current_user
    |> Map.fetch!(:id)
    |> FollowThrough.Obligation.for_user()
  end
end
