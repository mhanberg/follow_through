defmodule FollowThroughWeb.PageView do
  use FollowThroughWeb, :view

  def has_obligations?(user, team_id) do
    user.obligations
    |> FollowThrough.Obligation.for_team(team_id)
    |> Enum.empty?()
    |> Kernel.!()
  end

  def delete_obligation_link(conn, team, obligation) do
    if current_user(conn).id == obligation.user_id do
      link(
        svg_image(conn, "trash", class: "h-4 w-4"),
        to: Routes.team_obligation_path(conn, :delete, team.id, obligation.id),
        method: :delete,
        title: "Delete this obligation",
        class: "trash",
        data: [confirm: "Are you sure you want to delete this obligation?"]
      )
    end
  end
end
