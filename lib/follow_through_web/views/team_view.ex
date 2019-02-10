defmodule FollowThroughWeb.TeamView do
  use FollowThroughWeb, :view

  alias FollowThrough.Team

  def admin_or_remove_link(conn, team, user) do
    if team.created_by_id == user.id do
      svg_image(conn, "star-full", class: "h-4 w-4")
    else
      link(
        to: Routes.team_team_member_path(conn, :delete, team.id, user.id),
        method: :delete,
        title: "Remove team member from this team.",
        class: "hover:text-red-light",
        data: [confirm: "Are you sure you wan't to remove #{user.name}?"]
      ) do
        svg_image(conn, "trash", class: "h-4 w-4 fill-current")
      end
    end
  end
end
